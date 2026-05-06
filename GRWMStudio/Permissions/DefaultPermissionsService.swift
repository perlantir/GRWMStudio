import AVFAudio
import AVFoundation
import Photos
import UserNotifications

/// Production implementation backed by Apple permission APIs.
public struct DefaultPermissionsService: PermissionsService {
    /// Creates a default permissions service.
    public init() {}

    /// Current camera permission state.
    public func cameraStatus() async -> AppPermissionStatus {
        #if DEBUG
        if DebugRuntimeFlags.contains("-GRWMDebugCameraDenied") {
            return .denied
        }

        if DebugRuntimeFlags.contains("-GRWMDebugAppShell") {
            return .granted
        }
        #endif

        return mapCaptureStatus(AVCaptureDevice.authorizationStatus(for: .video))
    }

    /// Requests camera permission from an explicit user action.
    @MainActor
    public func requestCamera() async -> AppPermissionStatus {
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        return granted ? .granted : .denied
    }

    /// Current microphone permission state.
    public func micStatus() async -> AppPermissionStatus {
        #if DEBUG
        if DebugRuntimeFlags.contains("-GRWMDebugMicDenied") {
            return .denied
        }

        if DebugRuntimeFlags.contains("-GRWMDebugAppShell") {
            return .granted
        }
        #endif

        switch AVAudioApplication.shared.recordPermission {
        case .undetermined:
            return .notDetermined
        case .granted:
            return .granted
        case .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }

    /// Requests microphone permission from an explicit user action.
    @MainActor
    public func requestMic() async -> AppPermissionStatus {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted ? .granted : .denied)
            }
        }
    }

    /// Current photo-library add-only permission state.
    public func photosAddStatus() async -> AppPermissionStatus {
        #if DEBUG
        if DebugRuntimeFlags.contains("-GRWMDebugPhotosDenied") {
            return .denied
        }

        if DebugRuntimeFlags.contains("-GRWMDebugAppShell") {
            return .granted
        }
        #endif

        return mapPhotoStatus(PHPhotoLibrary.authorizationStatus(for: .addOnly))
    }

    /// Requests photo-library add-only permission from an explicit user action.
    @MainActor
    public func requestPhotosAdd() async -> AppPermissionStatus {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return mapPhotoStatus(status)
    }

    /// Current notification permission state.
    public func notificationsStatus() async -> AppPermissionStatus {
        #if DEBUG
        if DebugRuntimeFlags.contains("-GRWMDebugAppShell") {
            return .granted
        }
        #endif

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .authorized, .provisional, .ephemeral:
            return .granted
        case .denied:
            return .denied
        @unknown default:
            return .denied
        }
    }

    /// Requests notification permission from an explicit user action.
    @MainActor
    public func requestNotifications() async -> AppPermissionStatus {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted ? .granted : .denied
        } catch {
            return .denied
        }
    }

    private func mapCaptureStatus(_ status: AVAuthorizationStatus) -> AppPermissionStatus {
        switch status {
        case .notDetermined:
            .notDetermined
        case .authorized:
            .granted
        case .denied:
            .denied
        case .restricted:
            .restricted
        @unknown default:
            .denied
        }
    }

    private func mapPhotoStatus(_ status: PHAuthorizationStatus) -> AppPermissionStatus {
        switch status {
        case .notDetermined:
            .notDetermined
        case .authorized, .limited:
            .granted
        case .denied:
            .denied
        case .restricted:
            .restricted
        @unknown default:
            .denied
        }
    }
}
