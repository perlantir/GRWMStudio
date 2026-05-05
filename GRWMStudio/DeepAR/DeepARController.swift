import AVFoundation
import DeepAR
import Foundation
import Observation
import OSLog
import SwiftUI
import UIKit

/// Swift-native boundary around the DeepAR SDK.
@MainActor @Observable
public final class DeepARController: @unchecked Sendable {
    /// High-level DeepAR lifecycle state exposed to SwiftUI.
    public enum State: Equatable {
        /// The SDK has not been created yet.
        case uninitialized
        /// Bootstrap has started and is waiting for DeepAR initialization.
        case initializing
        /// DeepAR is initialized and ready for camera/effect calls.
        case ready
        /// DeepAR failed to initialize or run.
        case failed(reason: String)
    }

    /// Setup and runtime failures surfaced by the wrapper.
    public enum SetupError: LocalizedError {
        /// No DeepAR license key was configured.
        case missingLicenseKey
        /// The SDK did not initialize within the allowed timeout.
        case sdkInitTimeout
        /// Bootstrap was called after the SDK had already started.
        case alreadyInitialized
        /// An effect failed to load into a slot.
        case effectLoadFailed(slot: EffectSlot, reason: String)
        /// A video recording operation failed.
        case recordingFailed(reason: String)
        /// A photo capture operation failed.
        case captureFailed(reason: String)
        /// Placeholder used until later Phase 1 tickets fill the method.
        case notImplementedYet

        /// Human-readable diagnostic text.
        public var errorDescription: String? {
            switch self {
            case .missingLicenseKey:
                "Missing DeepAR license key in Info.plist"
            case .sdkInitTimeout:
                "DeepAR SDK didn't initialize within timeout"
            case .alreadyInitialized:
                "DeepAR is already initialized"
            case .effectLoadFailed(_, let reason):
                "Effect load failed: \(reason)"
            case .recordingFailed(let reason):
                "Recording failed: \(reason)"
            case .captureFailed(let reason):
                "Capture failed: \(reason)"
            case .notImplementedYet:
                "Not implemented yet (will land in a later ticket)"
            }
        }
    }

    /// Current DeepAR lifecycle state.
    var state: State = .uninitialized
    /// Whether DeepAR currently sees a tracked face.
    var trackedFace = false
    /// Whether the active or next camera session should use the front camera.
    var cameraIsFront = true
    /// Whether the active camera session includes audio input.
    var cameraIncludesAudio = false
    /// Effect IDs currently loaded by slot.
    var loadedEffects: [EffectSlot: EffectFile.ID] = [:]
    /// Whether video recording is active.
    public internal(set) var isRecordingVideo = false
    /// Current video recording duration.
    public internal(set) var recordingDuration: TimeInterval = 0

    /// UIKit rendering view hosted by `DeepARView`.
    public var arView: UIView? { _arView }

    @ObservationIgnored var _deepAR: DeepAR?
    @ObservationIgnored var _arView: UIView?
    @ObservationIgnored var _delegateProxy: DeepARDelegateProxy?
    @ObservationIgnored var _client: (any DeepARClient)?
    @ObservationIgnored var cameraController: CameraController?

    @ObservationIgnored var bootstrapContinuation: CheckedContinuation<Void, Error>?
    @ObservationIgnored var photoContinuation: CheckedContinuation<URL, Error>?
    @ObservationIgnored var screenshotContinuation: CheckedContinuation<UIImage, Error>?
    @ObservationIgnored var videoContinuation: CheckedContinuation<URL, Error>?
    @ObservationIgnored var recordingProgressTask: Task<Void, Never>?
    @ObservationIgnored var loadEffectContinuations: [EffectSlot: CheckedContinuation<Void, Error>] = [:]
    @ObservationIgnored var loadEffectRequestIDs: [EffectSlot: UUID] = [:]
    @ObservationIgnored var faceVisibilityContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
    @ObservationIgnored private let clientFactory: @MainActor () -> any DeepARClient
    @ObservationIgnored private let bootstrapTimeout: Duration
    @ObservationIgnored private let effectLoadTimeout: Duration

    /// Creates an uninitialized DeepAR controller.
    public init() {
        clientFactory = { LiveDeepARClient() }
        bootstrapTimeout = .seconds(8)
        effectLoadTimeout = .seconds(4)
    }

    init(
        clientFactory: @escaping @MainActor () -> any DeepARClient,
        bootstrapTimeout: Duration = .seconds(8),
        effectLoadTimeout: Duration = .seconds(4)
    ) {
        self.clientFactory = clientFactory
        self.bootstrapTimeout = bootstrapTimeout
        self.effectLoadTimeout = effectLoadTimeout
    }

    /// Bootstraps the DeepAR SDK.
    public func bootstrap(licenseKey: String = DeepARController.licenseKeyFromInfoPlist()) async throws {
        if state != .uninitialized {
            throw SetupError.alreadyInitialized
        }
        guard !licenseKey.isEmpty else {
            state = .failed(reason: "Missing license key")
            throw SetupError.missingLicenseKey
        }
        state = .initializing
        PerformanceSignposts.beginDeepARBootstrap()
        Logger.deepAR.info("Bootstrapping DeepAR")

        do {
            try await withTimeout(bootstrapTimeout) { [weak self] in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    Task { @MainActor in
                        guard let self else {
                            continuation.resume()
                            return
                        }

                        self.bootstrapContinuation = continuation
                        let client = self.clientFactory()
                        client.setLicenseKey(licenseKey)
                        let proxy = DeepARDelegateProxy(controller: self)
                        client.setDelegate(proxy)
                        client.setRenderingResolution(
                            width: Int(Self.previewResolution.width),
                            height: Int(Self.previewResolution.height)
                        )
                        self._client = client
                        self._deepAR = (client as? LiveDeepARClient)?.sdk
                        self._delegateProxy = proxy
                        self._arView = client.createARView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                    }
                }
            }
            state = .ready
            PerformanceSignposts.endDeepARBootstrap()
            Logger.deepAR.info("DeepAR bootstrap complete (state: ready)")
        } catch is TimeoutError {
            state = .failed(reason: "SDK init timeout")
            bootstrapContinuation?.resume(throwing: SetupError.sdkInitTimeout)
            bootstrapContinuation = nil
            PerformanceSignposts.endDeepARBootstrap()
            throw SetupError.sdkInitTimeout
        } catch {
            state = .failed(reason: error.localizedDescription)
            bootstrapContinuation = nil
            PerformanceSignposts.endDeepARBootstrap()
            throw error
        }
    }

    /// Starts the camera pipeline.
    public func startCamera(includeAudio: Bool) async throws {
        guard state == .ready else {
            throw SetupError.recordingFailed(reason: "DeepAR not ready")
        }
        guard let deepAR = _deepAR else {
            // Mock-backed tests have no live SDK camera pipeline; keep audio mode as logical state only.
            guard _client != nil else {
                throw SetupError.recordingFailed(reason: "Missing DeepAR instance")
            }
            cameraIncludesAudio = includeAudio
            Logger.deepAR.info("Camera start skipped for mock-backed DeepAR client (audio: \(includeAudio))")
            return
        }

        if cameraController == nil {
            cameraController = CameraController(deepAR: deepAR)
        }
        PerformanceSignposts.beginDeepARStartCamera()
        configureCameraController()
        cameraController?.position = cameraIsFront ? .front : .back
        cameraController?.startCamera(withAudio: includeAudio)
        _client?.resumeRendering()
        cameraIncludesAudio = includeAudio
        PerformanceSignposts.endDeepARStartCamera()
        Logger.deepAR.info("Camera started (audio: \(includeAudio))")
    }

    /// Restarts the active camera session when the requested audio mode changes.
    public func ensureCameraAudioMode(includeAudio: Bool) async throws {
        guard state == .ready else {
            throw SetupError.recordingFailed(reason: "DeepAR not ready")
        }

        if cameraController == nil {
            try await startCamera(includeAudio: includeAudio)
            return
        }

        guard cameraIncludesAudio != includeAudio else {
            return
        }

        cameraController?.stopCamera()
        configureCameraController()
        cameraController?.position = cameraIsFront ? .front : .back
        cameraController?.startCamera(withAudio: includeAudio)
        _client?.resumeRendering()
        cameraIncludesAudio = includeAudio
        Logger.deepAR.info("Camera audio mode updated (audio: \(includeAudio))")
    }

    /// Stops the camera pipeline.
    public func stopCamera() async {
        cameraController?.stopCamera()
        cameraController = nil
        cameraIncludesAudio = false
        trackedFace = false
        Logger.deepAR.info("Camera stopped")
    }

    /// Switches between front and rear cameras.
    public func switchCamera() async throws {
        try await switchCamera(toFront: !cameraIsFront)
    }

    /// Switches to a specific camera position.
    public func switchCamera(toFront: Bool) async throws {
        guard state == .ready else {
            throw SetupError.recordingFailed(reason: "DeepAR not ready")
        }
        guard let cameraController else {
            throw SetupError.recordingFailed(reason: "Camera not started")
        }

        cameraController.position = toFront ? .front : .back
        configureCameraController()
        cameraIsFront = toFront
        trackedFace = false
        Logger.deepAR.info("Camera switched (front: \(toFront))")
    }

    /// Loads an effect into a DeepAR slot.
    public func loadEffect(_ effect: EffectFile, slot: EffectSlot) async throws {
        guard state == .ready else {
            throw SetupError.effectLoadFailed(slot: slot, reason: "DeepAR not ready")
        }
        guard _client != nil else {
            throw SetupError.effectLoadFailed(slot: slot, reason: "Missing DeepAR instance")
        }

        let url = try effect.bundleURL()
        let requestID = UUID()
        let effectPath = url.path
        PerformanceSignposts.beginDeepARLoadEffect()
        Logger.deepAR.info("Loading effect \(effect.id) into \(slot.rawValue)")

        do {
            try await withTimeout(effectLoadTimeout) { [weak self] in
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    Task { @MainActor in
                        guard let self else {
                            continuation.resume()
                            return
                        }
                        self.beginEffectLoad(
                            slot: slot,
                            path: effectPath,
                            requestID: requestID,
                            continuation: continuation
                        )
                    }
                }
            }
            loadedEffects[slot] = effect.id
            PerformanceSignposts.endDeepARLoadEffect()
        } catch is TimeoutError {
            clearEffectLoadIfCurrent(slot: slot, requestID: requestID, reason: "Timeout")
            PerformanceSignposts.endDeepARLoadEffect()
            throw SetupError.effectLoadFailed(slot: slot, reason: "Timeout")
        } catch {
            clearEffectLoadIfCurrent(slot: slot, requestID: requestID, reason: nil)
            PerformanceSignposts.endDeepARLoadEffect()
            throw error
        }
    }

    /// Clears an effect from a DeepAR slot.
    public func clearEffect(slot: EffectSlot) async {
        Logger.deepAR.info("Clearing effect from \(slot.rawValue)")
        _client?.switchEffect(withSlot: slot.rawValue, path: nil)
        loadedEffects[slot] = nil
        loadEffectContinuations[slot]?.resume(
            throwing: SetupError.effectLoadFailed(slot: slot, reason: "Cleared")
        )
        loadEffectContinuations[slot] = nil
        loadEffectRequestIDs[slot] = nil
    }

    /// Clears every GRWM Studio effect slot.
    public func clearAllEffects() async {
        for slot in EffectSlot.allCases {
            await clearEffect(slot: slot)
        }
    }

}

extension DeepARController {
    func completeEffectLoad(slotRawValue: String) {
        Logger.deepAR.info("didSwitchEffect: \(slotRawValue)")
        if let slot = EffectSlot(rawValue: slotRawValue) {
            finishEffectLoad(slot: slot)
            return
        }

        guard loadEffectContinuations.count == 1, let slot = loadEffectContinuations.keys.first else {
            Logger.deepAR.info("Ignoring didSwitchEffect for unknown slot: \(slotRawValue)")
            return
        }

        Logger.deepAR.info("Mapping SDK effect callback \(slotRawValue) to pending slot \(slot.rawValue)")
        finishEffectLoad(slot: slot)
    }

    private func finishEffectLoad(slot: EffectSlot) {
        loadEffectContinuations[slot]?.resume()
        loadEffectContinuations[slot] = nil
        loadEffectRequestIDs[slot] = nil
    }

    func failPendingEffectLoads(reason: String) {
        for (slot, continuation) in loadEffectContinuations {
            continuation.resume(throwing: SetupError.effectLoadFailed(slot: slot, reason: reason))
        }
        loadEffectContinuations.removeAll()
        loadEffectRequestIDs.removeAll()
    }

    fileprivate func beginEffectLoad(
        slot: EffectSlot,
        path: String,
        requestID: UUID,
        continuation: CheckedContinuation<Void, Error>
    ) {
        guard let client = _client else {
            continuation.resume(
                throwing: SetupError.effectLoadFailed(slot: slot, reason: "Missing DeepAR instance")
            )
            return
        }

        if let existing = loadEffectContinuations[slot] {
            existing.resume(
                throwing: SetupError.effectLoadFailed(slot: slot, reason: "Cancelled by new load")
            )
        }
        loadEffectContinuations[slot] = continuation
        loadEffectRequestIDs[slot] = requestID
        client.switchEffect(withSlot: slot.rawValue, path: path)
    }

    fileprivate func clearEffectLoadIfCurrent(slot: EffectSlot, requestID: UUID, reason: String?) {
        guard loadEffectRequestIDs[slot] == requestID else {
            return
        }
        if let reason {
            loadEffectContinuations[slot]?.resume(
                throwing: SetupError.effectLoadFailed(slot: slot, reason: reason)
            )
        }
        loadEffectContinuations[slot] = nil
        loadEffectRequestIDs[slot] = nil
    }
}

extension DeepARController {
    /// Reads the DeepAR license key injected into the app Info.plist.
    public static func licenseKeyFromInfoPlist() -> String {
        (try? DeepARLicense.key()) ?? ""
    }
}
