import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class MirrorViewModel {
    enum State: Equatable {
        case idle
        case starting
        case running
        case needsPermission
        case failed(String)
    }

    private(set) var state: State = .idle
    let controller: DeepARController

    init(controller: DeepARController = DeepARController()) {
        self.controller = controller
    }

    func start(env: AppEnvironment) async {
        guard state != .starting else {
            return
        }

        let cameraStatus = await env.permissions.cameraStatus()
        guard cameraStatus == .granted else {
            state = .needsPermission
            Logger.deepAR.info("Mirror camera permission needed: \(String(describing: cameraStatus))")
            return
        }

        #if targetEnvironment(simulator)
        state = .running
        Logger.deepAR.info("Mirror using simulator DeepAR placeholder")
        return
        #else
        state = .starting

        do {
            if controller.state == .uninitialized {
                try await controller.bootstrap()
            }

            try await controller.startCamera(includeAudio: false)
            state = .running
        } catch {
            state = .failed(error.localizedDescription)
            Logger.deepAR.error("Mirror start failed: \(error.localizedDescription)")
        }
        #endif
    }

    func pause() {
        guard state == .running || state == .starting else {
            return
        }

        Task { @MainActor [controller] in
            await controller.stopCamera()
        }
        state = .idle
    }
}
