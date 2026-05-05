import AVFoundation
import Foundation
import Photos
import SwiftData

@MainActor
@Observable
final class SettingsViewModel {
    @ObservationIgnored private let modelContext: ModelContext
    @ObservationIgnored private let fileManager: FileManager

    var saveToPhotos: Bool {
        didSet { SettingsPreferences.saveToPhotos = saveToPhotos }
    }

    var blockShareExtensions: Bool {
        didSet { SettingsPreferences.blockShareExtensions = blockShareExtensions }
    }

    var soundEnabled: Bool {
        didSet { SettingsPreferences.soundEnabled = soundEnabled }
    }

    var hapticsEnabled: Bool {
        didSet { SettingsPreferences.hapticsEnabled = hapticsEnabled }
    }

    private(set) var profile: ProfileRecord

    init(modelContext: ModelContext, fileManager: FileManager = .default) {
        self.modelContext = modelContext
        self.fileManager = fileManager
        saveToPhotos = SettingsPreferences.saveToPhotos
        blockShareExtensions = SettingsPreferences.blockShareExtensions
        soundEnabled = SettingsPreferences.soundEnabled
        hapticsEnabled = SettingsPreferences.hapticsEnabled

        if let existingProfile = try? modelContext.fetch(FetchDescriptor<ProfileRecord>()).first {
            profile = existingProfile
        } else {
            let defaultProfile = ProfileRecord.makeDefault()
            modelContext.insert(defaultProfile)
            try? modelContext.save()
            profile = defaultProfile
        }
    }

    var cameraGranted: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    var microphoneGranted: Bool {
        AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
    }

    var versionString: String {
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
        return L10n.format("settings.about.version_value", shortVersion, build)
    }

    var parentEmailSummary: String {
        profile.parentEmailHashed == nil
            ? L10n.string("settings.account.parent_email_not_set")
            : L10n.string("settings.account.parent_email_saved")
    }

    var photosSummary: String {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            return saveToPhotos ? L10n.string("common.on") : L10n.string("common.off")
        case .denied, .restricted:
            return L10n.string("settings.privacy.photos_retry")
        case .notDetermined:
            return saveToPhotos ? L10n.string("common.on") : L10n.string("common.off")
        @unknown default:
            return saveToPhotos ? L10n.string("common.on") : L10n.string("common.off")
        }
    }

    func refreshProfile() {
        if let refreshedProfile = try? modelContext.fetch(FetchDescriptor<ProfileRecord>()).first {
            profile = refreshedProfile
        }
    }

    func deleteAllLooks() async {
        let capturesDirectory = URL.documentsURL.appendingPathComponent("captures", isDirectory: true)
        try? fileManager.removeItem(at: capturesDirectory)
        try? fileManager.createDirectory(at: capturesDirectory, withIntermediateDirectories: true)

        if let captures = try? modelContext.fetch(FetchDescriptor<SavedCapture>()) {
            for capture in captures {
                modelContext.delete(capture)
            }
        }

        try? modelContext.save()
    }
}
