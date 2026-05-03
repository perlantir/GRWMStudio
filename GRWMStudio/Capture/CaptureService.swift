import Foundation
import UIKit

/// Writes captured photos and videos into the app's local captures directory.
public actor CaptureService {
    /// Creates a capture service.
    public init() {}

    /// Writes a JPEG capture and returns its file URL.
    @discardableResult
    public static func writeImage(_ image: UIImage) throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.92) else {
            throw CaptureServiceError.jpegEncodingFailed
        }

        let url = URL.documentsCapturesURL.appendingPathComponent("\(UUID()).jpg")
        try data.write(to: url, options: .atomic)
        return url
    }

    /// Moves a recorded video into the captures directory and returns its file URL.
    @discardableResult
    public static func moveVideo(from sourcePath: String) throws -> URL {
        let sourceURL = URL(fileURLWithPath: sourcePath)
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw CaptureServiceError.videoFileMissing(sourcePath)
        }

        let destinationURL = URL.documentsCapturesURL.appendingPathComponent("\(UUID()).mp4")
        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }

    /// Moves a recorded video into temporary storage and preserves its container extension.
    @discardableResult
    public static func moveVideoToTemporaryVideo(from sourcePath: String) throws -> URL {
        let sourceURL = URL(fileURLWithPath: sourcePath)
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw CaptureServiceError.videoFileMissing(sourcePath)
        }

        let sourceExtension = sourceURL.pathExtension.isEmpty ? "mov" : sourceURL.pathExtension
        let destinationURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("rec_\(UUID().uuidString).\(sourceExtension)")
        try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }
}

/// Capture persistence failures.
public enum CaptureServiceError: LocalizedError {
    /// JPEG encoding failed.
    case jpegEncodingFailed
    /// DeepAR reported a video file that does not exist.
    case videoFileMissing(String)

    /// Human-readable diagnostic text.
    public var errorDescription: String? {
        switch self {
        case .jpegEncodingFailed:
            "JPEG encoding failed"
        case .videoFileMissing(let path):
            "Video file missing: \(path)"
        }
    }
}
