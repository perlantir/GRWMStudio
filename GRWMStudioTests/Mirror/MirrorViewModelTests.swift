@testable import GRWMStudio
import XCTest

@MainActor
final class MirrorViewModelTests: XCTestCase {
    func testStartWithoutCameraPermissionDoesNotRequestSystemPrompt() async {
        let permissions = MirrorPermissionsStub(camera: .notDetermined)
        let environment = AppEnvironment(permissions: permissions)
        let viewModel = MirrorViewModel()

        await viewModel.start(env: environment)

        XCTAssertEqual(viewModel.state, .needsPermission)
        XCTAssertFalse(permissions.requestedCamera)
    }

    func testPauseFromPermissionStateLeavesStateAlone() {
        let viewModel = MirrorViewModel()

        viewModel.pause()

        XCTAssertEqual(viewModel.state, .idle)
    }
}

private final class MirrorPermissionsStub: PermissionsService, @unchecked Sendable {
    private let camera: AppPermissionStatus
    private(set) var requestedCamera = false

    init(camera: AppPermissionStatus) {
        self.camera = camera
    }

    func cameraStatus() async -> AppPermissionStatus {
        camera
    }

    @MainActor
    func requestCamera() async -> AppPermissionStatus {
        requestedCamera = true
        return camera
    }

    func micStatus() async -> AppPermissionStatus {
        .granted
    }

    @MainActor
    func requestMic() async -> AppPermissionStatus {
        .granted
    }

    func photosAddStatus() async -> AppPermissionStatus {
        .granted
    }

    @MainActor
    func requestPhotosAdd() async -> AppPermissionStatus {
        .granted
    }

    func notificationsStatus() async -> AppPermissionStatus {
        .denied
    }

    @MainActor
    func requestNotifications() async -> AppPermissionStatus {
        .denied
    }
}
