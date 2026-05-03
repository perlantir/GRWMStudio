import OSLog
@preconcurrency import Photos
import SwiftUI
import UIKit

struct PreviewPlaceholderView: View {
    let asset: CapturedAsset
    let onClose: () -> Void
    @State private var saveState: SaveState = .idle
    @State private var activeSaver: PhotoLibrarySaver?

    var body: some View {
        ZStack {
            DHWallpaperGradient()
                .ignoresSafeArea()

            VStack(spacing: 14) {
                topBar
                mediaCard
                bottomControls
            }
            .safeAreaPadding(.top, 10)
            .padding(.bottom, 24)
        }
        .preferredColorScheme(.light)
        .accessibilityIdentifier("preview-placeholder")
    }

    private var topBar: some View {
        HStack {
            Button {
                onClose()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .heavy))

                    Text("Mirror")
                        .font(DH.font(.buttonSmall))
                        .tracking(DH.tracking(.buttonSmall))
                }
                .foregroundStyle(DH.pinkDeep)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background {
                    Capsule()
                        .fill(.white)
                        .chunkyShadow(.sm(deep: DH.pinkDeep), shape: Capsule())
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to mirror")

            Spacer()
        }
        .padding(.horizontal, 18)
    }

    private var mediaCard: some View {
        assetView
            .clipShape(RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
            .overlay {
                RoundedRectangle(cornerRadius: DH.Radius.viewportInner)
                    .strokeBorder(.white, lineWidth: 6)
            }
            .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .layoutPriority(1)
    }

    private var bottomControls: some View {
        VStack(spacing: 12) {
            Text(statusTitle)
                .font(DH.font(.caption))
                .tracking(DH.tracking(.caption))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(.white.opacity(0.92)))

            HStack(spacing: 12) {
                DHButton(
                    title: saveButtonTitle,
                    kind: .primary,
                    size: .md,
                    leadingIcon: AnyView(Image(systemName: "square.and.arrow.down")),
                    isFullWidth: true
                ) {
                    Task { @MainActor in
                        await saveToPhotos()
                    }
                }
                .disabled(saveState == .saving)

                DHButton(
                    title: "Done",
                    kind: .white,
                    size: .md,
                    isFullWidth: true,
                    action: onClose
                )
            }
        }
        .padding(.horizontal, 18)
    }

    @ViewBuilder
    private var assetView: some View {
        switch asset {
        case .photo(let image):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .accessibilityLabel("Captured photo preview")

        case .video:
            ZStack {
                DH.pinkPaper
                Image(systemName: "play.fill")
                    .font(.system(size: 54, weight: .heavy))
                    .foregroundStyle(DH.pinkDeep)
            }
            .accessibilityLabel("Captured video preview")
        }
    }

    private var previewTitle: String {
        switch asset {
        case .photo:
            "Photo Preview"
        case .video:
            "Video Preview"
        }
    }

    private var statusTitle: String {
        switch saveState {
        case .idle:
            previewTitle
        case .saving:
            "Saving..."
        case .saved:
            "Saved to Photos"
        case .failed:
            "Saving needs a reset"
        }
    }

    private var statusColor: Color {
        switch saveState {
        case .failed:
            DH.recRedDeep
        default:
            DH.pinkDeep
        }
    }

    private var saveButtonTitle: String {
        switch saveState {
        case .saving:
            "Saving"
        case .saved:
            "Saved"
        default:
            "Save"
        }
    }

    @MainActor
    private func saveToPhotos() async {
        guard saveState != .saving else {
            return
        }

        saveState = .saving
        let saver = PhotoLibrarySaver()
        activeSaver = saver
        defer { activeSaver = nil }

        do {
            try await saver.save(asset: asset)
            saveState = .saved
        } catch {
            Logger.capture.error("Preview save failed: \(error.localizedDescription, privacy: .public)")
            saveState = .failed
        }
    }
}

private enum SaveState {
    case idle
    case saving
    case saved
    case failed
}

private enum PreviewSaveError: Error {
    case imageEncodingFailed
    case missingVideoFile
    case emptyVideoFile
    case incompatibleVideoFile
    case photoAccessDenied
    case photoLibraryChangeFailed
}

extension PreviewSaveError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .imageEncodingFailed:
            "Photo could not be prepared for saving."
        case .missingVideoFile:
            "Video file is missing."
        case .emptyVideoFile:
            "Video file is empty."
        case .incompatibleVideoFile:
            "Video file is not compatible with Photos."
        case .photoAccessDenied:
            "Photos access was not granted."
        case .photoLibraryChangeFailed:
            "Photos could not save the capture."
        }
    }
}

private enum SavePayload {
    case photo(UIImage)
    case video(URL)

    init(asset: CapturedAsset) throws {
        switch asset {
        case .photo(let image):
            guard image.jpegData(compressionQuality: 0.95)?.isEmpty == false else {
                throw PreviewSaveError.imageEncodingFailed
            }
            self = .photo(image)

        case .video(let url):
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw PreviewSaveError.missingVideoFile
            }

            let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
            guard size > 0 else {
                throw PreviewSaveError.emptyVideoFile
            }

            self = .video(url)
        }
    }
}

private final class PhotoLibrarySaver: @unchecked Sendable {
    func save(asset: CapturedAsset) async throws {
        let payload = try SavePayload(asset: asset)
        try await requestAddOnlyAccess()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                switch payload {
                case .photo(let image):
                    PHAssetChangeRequest.creationRequestForAsset(from: image)

                case .video(let url):
                    guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(url.path) else {
                        return
                    }
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? PreviewSaveError.photoLibraryChangeFailed)
                }
            }
        }
    }

    private func requestAddOnlyAccess() async throws {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        let resolvedStatus: PHAuthorizationStatus

        if status == .notDetermined {
            resolvedStatus = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        } else {
            resolvedStatus = status
        }

        switch resolvedStatus {
        case .authorized, .limited:
            return
        case .denied, .restricted, .notDetermined:
            throw PreviewSaveError.photoAccessDenied
        @unknown default:
            throw PreviewSaveError.photoAccessDenied
        }
    }
}
