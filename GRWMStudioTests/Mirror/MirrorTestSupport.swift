@testable import GRWMStudio
import UIKit

final class MirrorPermissionsStub: PermissionsService, @unchecked Sendable {
    private let camera: AppPermissionStatus
    private let mic: AppPermissionStatus
    private let photos: AppPermissionStatus
    private(set) var requestedCamera = false

    init(
        camera: AppPermissionStatus,
        mic: AppPermissionStatus = .granted,
        photos: AppPermissionStatus = .granted
    ) {
        self.camera = camera
        self.mic = mic
        self.photos = photos
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
        mic
    }

    @MainActor
    func requestMic() async -> AppPermissionStatus {
        mic
    }

    func photosAddStatus() async -> AppPermissionStatus {
        photos
    }

    @MainActor
    func requestPhotosAdd() async -> AppPermissionStatus {
        photos
    }

    func notificationsStatus() async -> AppPermissionStatus {
        .denied
    }

    @MainActor
    func requestNotifications() async -> AppPermissionStatus {
        .denied
    }
}

@MainActor
final class MirrorMockDeepARClient: DeepARClient {
    struct Switch: Equatable {
        let slot: String
        let path: String?
    }

    struct VectorParameter {
        let gameObject: String
        let parameter: String
        let value: DeepARVectorParameter
    }

    struct BoolParameter {
        let gameObject: String
        let parameter: String
        let value: Bool
    }

    struct FloatParameter {
        let gameObject: String
        let parameter: String
        let value: Float
    }

    struct ImageParameter {
        let gameObject: String
        let parameter: String
    }

    private let autoInitialize: Bool
    private let autoSwitchEffect: Bool
    private(set) var delegate: DeepARDelegateProxy?
    private(set) var switches: [Switch] = []
    private(set) var vectorParameters: [VectorParameter] = []
    private(set) var boolParameters: [BoolParameter] = []
    private(set) var floatParameters: [FloatParameter] = []
    private(set) var imageParameters: [ImageParameter] = []
    private(set) var createARViewCount = 0
    private(set) var pauseRenderingCount = 0
    private(set) var resumeRenderingCount = 0
    private(set) var didShutdown = false

    init(autoInitialize: Bool, autoSwitchEffect: Bool) {
        self.autoInitialize = autoInitialize
        self.autoSwitchEffect = autoSwitchEffect
    }

    func setLicenseKey(_ licenseKey: String) {}

    func setDelegate(_ delegate: DeepARDelegateProxy) {
        self.delegate = delegate
    }

    func createARView(frame: CGRect) -> UIView {
        createARViewCount += 1
        if autoInitialize {
            Task { @MainActor [weak self] in
                self?.delegate?.didInitialize()
            }
        }
        return UIView(frame: frame)
    }

    func switchEffect(withSlot slot: String, path: String?) {
        switches.append(Switch(slot: slot, path: path))
        if autoSwitchEffect {
            Task { @MainActor [weak self] in
                self?.delegate?.didSwitchEffect(slot)
            }
        }
    }

    func setVectorParameter(
        _ gameObject: String,
        component: String,
        parameter: String,
        value: DeepARVectorParameter
    ) {
        vectorParameters.append(VectorParameter(gameObject: gameObject, parameter: parameter, value: value))
    }

    func setBoolParameter(_ gameObject: String, component: String, parameter: String, value: Bool) {
        boolParameters.append(BoolParameter(gameObject: gameObject, parameter: parameter, value: value))
    }

    func setFloatParameter(_ gameObject: String, component: String, parameter: String, value: Float) {
        floatParameters.append(FloatParameter(gameObject: gameObject, parameter: parameter, value: value))
    }

    func setImageParameter(_ gameObject: String, component: String, parameter: String, image: UIImage) {
        imageParameters.append(ImageParameter(gameObject: gameObject, parameter: parameter))
    }

    func pauseRendering() {
        pauseRenderingCount += 1
    }

    func resumeRendering() {
        resumeRenderingCount += 1
    }

    func shutdown() {
        didShutdown = true
    }
}
