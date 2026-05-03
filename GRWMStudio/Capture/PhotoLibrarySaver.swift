import Foundation
@preconcurrency import Photos
import UIKit

enum PreviewSaveError: Error {
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

final class PhotoLibrarySaver: @unchecked Sendable {
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
