import AVFoundation
import DeepAR
import Foundation
import Observation
import OSLog
import SwiftUI
import UIKit

/// Swift-native boundary around the DeepAR SDK.
@MainActor @Observable
public final class DeepARController {
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
    public private(set) var state: State = .uninitialized
    /// Whether DeepAR currently sees a tracked face.
    public private(set) var trackedFace = false
    /// Effect IDs currently loaded by slot.
    public private(set) var loadedEffects: [EffectSlot: EffectFile.ID] = [:]
    /// Whether video recording is active.
    public private(set) var isRecordingVideo = false
    /// Current video recording duration.
    public private(set) var recordingDuration: TimeInterval = 0

    /// UIKit rendering view hosted by `DeepARView`.
    public var arView: UIView? { _arView }

    @ObservationIgnored var _deepAR: DeepAR?
    @ObservationIgnored var _arView: UIView?
    @ObservationIgnored var _delegateProxy: DeepARDelegateProxy?
    @ObservationIgnored var _client: (any DeepARClient)?
    @ObservationIgnored private var _cameraController: CameraController?

    @ObservationIgnored var bootstrapContinuation: CheckedContinuation<Void, Error>?
    @ObservationIgnored var photoContinuation: CheckedContinuation<URL, Error>?
    @ObservationIgnored var videoContinuation: CheckedContinuation<URL, Error>?
    @ObservationIgnored private let clientFactory: @MainActor () -> any DeepARClient
    @ObservationIgnored private let bootstrapTimeout: Duration

    /// Creates an uninitialized DeepAR controller.
    public init() {
        clientFactory = { LiveDeepARClient() }
        bootstrapTimeout = .seconds(8)
    }

    init(
        clientFactory: @escaping @MainActor () -> any DeepARClient,
        bootstrapTimeout: Duration = .seconds(8)
    ) {
        self.clientFactory = clientFactory
        self.bootstrapTimeout = bootstrapTimeout
    }

    func updateTrackedFace(_ isTracked: Bool) {
        trackedFace = isTracked
    }

    func completeBootstrapFromDelegate() {
        bootstrapContinuation?.resume()
        bootstrapContinuation = nil
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
                        self._client = client
                        self._deepAR = (client as? LiveDeepARClient)?.sdk
                        self._delegateProxy = proxy
                        self._arView = client.createARView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
                    }
                }
            }
            state = .ready
            Logger.deepAR.info("DeepAR bootstrap complete (state: ready)")
        } catch is TimeoutError {
            state = .failed(reason: "SDK init timeout")
            bootstrapContinuation?.resume(throwing: SetupError.sdkInitTimeout)
            bootstrapContinuation = nil
            throw SetupError.sdkInitTimeout
        } catch {
            state = .failed(reason: error.localizedDescription)
            bootstrapContinuation = nil
            throw error
        }
    }

    /// Starts the camera pipeline.
    public func startCamera(includeAudio: Bool) async throws {
        guard state == .ready else {
            throw SetupError.recordingFailed(reason: "DeepAR not ready")
        }
        guard let deepAR = _deepAR else {
            throw SetupError.recordingFailed(reason: "Missing DeepAR instance")
        }

        if _cameraController == nil {
            _cameraController = CameraController(deepAR: deepAR)
        }
        _cameraController?.startCamera(withAudio: includeAudio)
        Logger.deepAR.info("Camera started (audio: \(includeAudio))")
    }

    /// Stops the camera pipeline.
    public func stopCamera() async {
        _cameraController?.stopCamera()
        _cameraController = nil
        trackedFace = false
        Logger.deepAR.info("Camera stopped")
    }

    /// Switches between front and rear cameras.
    public func switchCamera(toFront: Bool) async throws {
        guard state == .ready else {
            throw SetupError.recordingFailed(reason: "DeepAR not ready")
        }
        guard let cameraController = _cameraController else {
            throw SetupError.recordingFailed(reason: "Camera not started")
        }

        cameraController.position = toFront ? .front : .back
        trackedFace = false
        Logger.deepAR.info("Camera switched (front: \(toFront))")
    }

    /// Loads an effect into a DeepAR slot.
    public func loadEffect(_ effect: EffectFile, slot: EffectSlot) async throws {
        throw SetupError.notImplementedYet
    }

    /// Clears an effect from a DeepAR slot.
    public func clearEffect(slot: EffectSlot) async {}

    /// Clears every GRWM Studio effect slot.
    public func clearAllEffects() async {
        for slot in EffectSlot.allCases {
            await clearEffect(slot: slot)
        }
    }

    /// Sets a color parameter on the active DeepAR scene.
    public func setColor(_ color: UIColor, on parameter: EffectParameter) async {}

    /// Sets a texture parameter on the active DeepAR scene.
    public func setTexture(_ image: UIImage, on parameter: EffectParameter) async {}

    /// Sets a blendshape parameter on the active DeepAR scene.
    public func setBlendshape(_ value: Float, on parameter: EffectParameter) async {}

    /// Sets an enabled-state parameter on the active DeepAR scene.
    public func setEnabled(_ enabled: Bool, on parameter: EffectParameter) async {}

    /// Captures the current DeepAR preview to a temporary file.
    public func capturePhoto() async throws -> URL {
        throw SetupError.notImplementedYet
    }

    /// Starts video recording for the current DeepAR preview.
    public func startVideoRecording(maxDuration: TimeInterval) async throws {
        throw SetupError.notImplementedYet
    }

    /// Stops video recording and returns the recorded file URL.
    public func stopVideoRecording() async throws -> URL {
        throw SetupError.notImplementedYet
    }
}

extension DeepARController {
    /// Reads the DeepAR license key injected into the app Info.plist.
    public static func licenseKeyFromInfoPlist() -> String {
        Bundle.main.object(forInfoDictionaryKey: "DeepARLicenseKey") as? String ?? ""
    }
}

@MainActor
protocol DeepARClient: AnyObject {
    func setLicenseKey(_ licenseKey: String)
    func setDelegate(_ delegate: DeepARDelegateProxy)
    func createARView(frame: CGRect) -> UIView
}

@MainActor
final class LiveDeepARClient: DeepARClient {
    let sdk: DeepAR

    init(sdk: DeepAR = DeepAR()) {
        self.sdk = sdk
    }

    func setLicenseKey(_ licenseKey: String) {
        sdk.setLicenseKey(licenseKey)
    }

    func setDelegate(_ delegate: DeepARDelegateProxy) {
        sdk.delegate = delegate
    }

    func createARView(frame: CGRect) -> UIView {
        sdk.createARView(withFrame: frame)
    }
}
