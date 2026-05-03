@testable import GRWMStudio
import XCTest

@MainActor
final class PermissionsServiceTests: XCTestCase {
    func testCameraRequestPromotesNotDeterminedToGranted() async {
        let service = MockPermissionsService()

        let status = await service.requestCamera()
        let currentStatus = await service.cameraStatus()

        XCTAssertEqual(status, .granted)
        XCTAssertEqual(currentStatus, .granted)
        XCTAssertTrue(service.requestedCamera)
    }

    func testDeniedCameraRequestStaysDenied() async {
        let service = MockPermissionsService(camera: .denied)

        let status = await service.requestCamera()

        XCTAssertEqual(status, .denied)
        XCTAssertTrue(service.requestedCamera)
    }

    func testMicPhotosAndNotificationsRequestsAreTracked() async {
        let service = MockPermissionsService()

        let mic = await service.requestMic()
        let photos = await service.requestPhotosAdd()
        let notifications = await service.requestNotifications()

        XCTAssertEqual(mic, .granted)
        XCTAssertEqual(photos, .granted)
        XCTAssertEqual(notifications, .granted)

        XCTAssertTrue(service.requestedMic)
        XCTAssertTrue(service.requestedPhotos)
        XCTAssertTrue(service.requestedNotifications)
    }

    func testRestrictedStatusesDoNotPromoteOnRequest() async {
        let service = MockPermissionsService(
            camera: .restricted,
            mic: .restricted,
            photos: .restricted,
            notifications: .denied
        )

        let camera = await service.requestCamera()
        let mic = await service.requestMic()
        let photos = await service.requestPhotosAdd()
        let notifications = await service.requestNotifications()

        XCTAssertEqual(camera, .restricted)
        XCTAssertEqual(mic, .restricted)
        XCTAssertEqual(photos, .restricted)
        XCTAssertEqual(notifications, .denied)
    }

    func testAppEnvironmentUsesDefaultPermissionsService() {
        let environment = AppEnvironment()

        XCTAssertTrue(environment.permissions is DefaultPermissionsService)
    }
}

private final class MockPermissionsService: PermissionsService, @unchecked Sendable {
    private(set) var camera: AppPermissionStatus
    private(set) var mic: AppPermissionStatus
    private(set) var photos: AppPermissionStatus
    private(set) var notifications: AppPermissionStatus
    private(set) var requestedCamera = false
    private(set) var requestedMic = false
    private(set) var requestedPhotos = false
    private(set) var requestedNotifications = false

    init(
        camera: AppPermissionStatus = .notDetermined,
        mic: AppPermissionStatus = .notDetermined,
        photos: AppPermissionStatus = .notDetermined,
        notifications: AppPermissionStatus = .notDetermined
    ) {
        self.camera = camera
        self.mic = mic
        self.photos = photos
        self.notifications = notifications
    }

    func cameraStatus() async -> AppPermissionStatus {
        camera
    }

    @MainActor
    func requestCamera() async -> AppPermissionStatus {
        requestedCamera = true
        camera = requestedStatus(from: camera)
        return camera
    }

    func micStatus() async -> AppPermissionStatus {
        mic
    }

    @MainActor
    func requestMic() async -> AppPermissionStatus {
        requestedMic = true
        mic = requestedStatus(from: mic)
        return mic
    }

    func photosAddStatus() async -> AppPermissionStatus {
        photos
    }

    @MainActor
    func requestPhotosAdd() async -> AppPermissionStatus {
        requestedPhotos = true
        photos = requestedStatus(from: photos)
        return photos
    }

    func notificationsStatus() async -> AppPermissionStatus {
        notifications
    }

    @MainActor
    func requestNotifications() async -> AppPermissionStatus {
        requestedNotifications = true
        notifications = requestedStatus(from: notifications)
        return notifications
    }

    private func requestedStatus(from status: AppPermissionStatus) -> AppPermissionStatus {
        status == .notDetermined ? .granted : status
    }
}
