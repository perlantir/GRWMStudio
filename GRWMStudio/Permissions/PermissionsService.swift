/// Reads and requests app permissions.
public protocol PermissionsService: Sendable {
    /// Current camera permission state.
    func cameraStatus() async -> AppPermissionStatus
    /// Requests camera permission from an explicit user action.
    @MainActor func requestCamera() async -> AppPermissionStatus

    /// Current microphone permission state.
    func micStatus() async -> AppPermissionStatus
    /// Requests microphone permission from an explicit user action.
    @MainActor func requestMic() async -> AppPermissionStatus

    /// Current photo-library add-only permission state.
    func photosAddStatus() async -> AppPermissionStatus
    /// Requests photo-library add-only permission from an explicit user action.
    @MainActor func requestPhotosAdd() async -> AppPermissionStatus

    /// Current notification permission state.
    func notificationsStatus() async -> AppPermissionStatus
    /// Requests notification permission from an explicit user action.
    @MainActor func requestNotifications() async -> AppPermissionStatus
}
