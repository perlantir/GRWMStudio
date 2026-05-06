import OSLog
import SwiftUI

extension RootContainer {
    @ViewBuilder
    func previewView(for asset: CapturedAsset) -> some View {
        PreviewPlaceholderView(
            asset: asset,
            lookName: coordinator.previewLookName,
            onSave: {
                await savePreview(asset: asset)
            },
            onExportToPhotos: {
                gateExportToPhotos(
                    asset: asset,
                    successMessage: L10n.string("root.toast.saved_photos"),
                    completion: nil
                )
            },
            onDiscard: {
                discardPreviewAssetAndReturnToMirror()
            }
        )
    }

    func savePreview(asset: CapturedAsset) async {
        guard StorageMonitor.canSave else {
            coordinator.presentError(.lowStorage)
            return
        }

        let service = CaptureSaveService(modelContext)
        do {
            _ = try await service.save(
                asset: asset,
                lookName: coordinator.previewLookName,
                shadeIDs: coordinator.previewShadeIDs
            )

            if SettingsPreferences.saveToPhotos {
                gateExportToPhotos(
                    asset: asset,
                    successMessage: L10n.string("root.toast.saved_locker_and_photos")
                ) {
                    coordinator.dismissPreviewSaved()
                }
                return
            }

            coordinator.showToast(L10n.string("root.toast.saved_locker_only"))
            coordinator.dismissPreviewSaved()
        } catch CaptureServiceError.capacityExceeded {
            coordinator.presentError(.lowStorage)
        } catch CaptureServiceError.lockerAtLimit {
            coordinator.startParentGate(intent: .paywall(source: .lockerLimit))
        } catch {
            coordinator.presentError(.saveFail)
        }
    }

    func discardPreviewAssetAndReturnToMirror() {
        if case .video(let url) = coordinator.previewAsset {
            try? FileManager.default.removeItem(at: url)
        }
        coordinator.dismissPreview()
    }

    func gateExportToPhotos(
        asset: CapturedAsset,
        successMessage: String,
        completion: (@MainActor () -> Void)?
    ) {
        coordinator.startParentGate(intent: .saveToPhotos) {
            await exportToPhotos(asset: asset, successMessage: successMessage, completion: completion)
        }
    }

    func exportToPhotos(
        asset: CapturedAsset,
        successMessage: String,
        completion: (@MainActor () -> Void)?
    ) async {
        let status = await env.permissions.photosAddStatus()

        switch status {
        case .denied, .restricted:
            coordinator.presentError(.photoDenied)
            completion?()
            return
        case .notDetermined:
            let requested = await env.permissions.requestPhotosAdd()
            guard requested == .granted else {
                coordinator.presentError(.photoDenied)
                completion?()
                return
            }
        case .granted:
            break
        }

        do {
            try await PhotoLibrarySaver().save(asset: asset)
            coordinator.showToast(successMessage)
        } catch {
            coordinator.showToast(L10n.string("root.toast.saved_locker_photos_permission"))
        }

        completion?()
    }

    func resolveInitialRoute() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugAppShell") {
            coordinator.route = .app
            return
        }

        if ProcessInfo.processInfo.arguments.contains("-GRWMDebugOnboardingFlow") {
            return
        }
        #endif

        if env.onboarding.hasCompletedOnboarding {
            coordinator.route = .app
        } else if coordinator.route == .app {
            coordinator.route = .onboardingSplash
        }
    }

    func loadEffectCatalog() async {
        do {
            _ = try await EffectCatalog.shared.load()
            Logger.deepAR.info("Effect catalog loaded")
        } catch {
            Logger.deepAR.error("Catalog load failed: \(error.localizedDescription)")
            coordinator.presentError(.effectFail)
        }
    }
}
