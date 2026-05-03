import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class MirrorViewModel {
    let controller: DeepARController
    let catalog: EffectCatalog

    private(set) var state: MirrorState = .idle
    var selections: [EffectSlot: SlotSelection] = [:]
    var eyeSelections: [EyesSubCategory: String] = [:]
    private(set) var isFaceDetected = false
    var cameraIsFront = true
    var flashEnabled = false
    var lastError: ErrorVariant?
    var activeLookName: String?
    var activeCategory: FilterCategory?
    var eyesSubCategory: EyesSubCategory = .shadow
    var activeCaptureMode: CaptureMode = .idle
    var lastCaptureEvent: CaptureEvent?
    var activeTraySlot: EffectSlot? {
        activeCategory?.slot
    }

    @ObservationIgnored private var env: AppEnvironment?
    @ObservationIgnored private var faceTask: Task<Void, Never>?
    @ObservationIgnored private let licenseLoader: () throws -> String
    @ObservationIgnored private let usesSimulatorPlaceholder: Bool
    @ObservationIgnored var lastShadeSelection: (slot: EffectSlot, shade: Shade)?
    @ObservationIgnored var effectFailureCount = 0
    @ObservationIgnored var effectFailureWindowStart: Date?
    @ObservationIgnored let currentDate: () -> Date
    @ObservationIgnored var capturePressStartedAt: Date?
    @ObservationIgnored var captureTickTask: Task<Void, Never>?

    init(
        controller: DeepARController = DeepARController(),
        catalog: EffectCatalog = .shared,
        licenseLoader: @escaping () throws -> String = { try DeepARLicense.key() },
        usesSimulatorPlaceholder: Bool = MirrorViewModel.defaultUsesSimulatorPlaceholder,
        currentDate: @escaping () -> Date = Date.init
    ) {
        self.controller = controller
        self.catalog = catalog
        self.licenseLoader = licenseLoader
        self.usesSimulatorPlaceholder = usesSimulatorPlaceholder
        self.currentDate = currentDate
    }

    func start(env: AppEnvironment) async {
        guard state != .starting && state != .running else {
            return
        }

        self.env = env
        state = .starting
        let cameraStatus = await env.permissions.cameraStatus()
        guard cameraStatus == .granted else {
            state = .needsPermission
            Logger.deepAR.info("Mirror camera permission needed: \(String(describing: cameraStatus))")
            return
        }

        observeFaceVisibility()

        let licenseKey: String
        do {
            licenseKey = try licenseLoader()
        } catch {
            state = .failed(.licenseInvalid)
            lastError = .licenseInvalid
            Logger.mirror.error("DeepAR license missing or empty")
            return
        }

        if usesSimulatorPlaceholder {
            state = .running
            applyDebugCaptureModeIfNeeded()
            Logger.deepAR.info("Mirror using simulator DeepAR placeholder")
            return
        }

        do {
            if controller.state == .uninitialized {
                try await controller.bootstrap(licenseKey: licenseKey)
            }

            try await controller.startCamera(includeAudio: false)
            state = .running
            applyDebugCaptureModeIfNeeded()
        } catch DeepARController.SetupError.missingLicenseKey {
            state = .failed(.licenseInvalid)
            lastError = .licenseInvalid
            Logger.mirror.error("DeepAR license rejected as missing during bootstrap")
        } catch DeepARController.SetupError.sdkInitTimeout {
            state = .failed(.effectFail)
            lastError = .effectFail
            Logger.mirror.error("DeepAR bootstrap timed out")
        } catch {
            state = .failed(.effectFail)
            lastError = .effectFail
            Logger.deepAR.error("Mirror start failed: \(error.localizedDescription)")
        }
    }

    func pause() {
        faceTask?.cancel()
        faceTask = nil
        captureTickTask?.cancel()
        captureTickTask = nil
        capturePressStartedAt = nil
        activeCaptureMode = .idle
        isFaceDetected = false

        if state == .running || state == .starting {
            Task { @MainActor [controller] in
                await controller.stopCamera()
            }
            state = .idle
        }
    }

    func canUseProContent(isPro: Bool) -> Bool {
        guard isPro else {
            return true
        }
        return env?.proEntitlement.hasPro == true
    }

    func escalateEffectFailure() {
        state = .failed(.effectFail)
    }

    private func observeFaceVisibility() {
        faceTask?.cancel()
        let stream = controller.faceVisibilityStream
        isFaceDetected = controller.trackedFace
        faceTask = Task { @MainActor [weak self] in
            for await visible in stream {
                guard let self else {
                    return
                }
                self.isFaceDetected = visible
            }
        }
    }

    var shouldSkipControllerCallsForSimulator: Bool {
        #if targetEnvironment(simulator)
        controller.state != .ready
        #else
        false
        #endif
    }

    private static var defaultUsesSimulatorPlaceholder: Bool {
        #if targetEnvironment(simulator)
        true
        #else
        false
        #endif
    }

    private func applyDebugCaptureModeIfNeeded() {
        #if DEBUG
        guard ProcessInfo.processInfo.arguments.contains("-GRWMDebugCaptureRecording") else {
            return
        }

        activeCaptureMode = .videoRecording(secondsElapsed: 5)
        #endif
    }
}
