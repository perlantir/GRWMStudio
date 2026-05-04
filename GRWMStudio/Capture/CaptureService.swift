import Foundation
import SwiftData
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

@MainActor
final class CaptureSaveService {
    private let modelContext: ModelContext
    private let fileManager: FileManager

    init(_ modelContext: ModelContext, fileManager: FileManager = .default) {
        self.modelContext = modelContext
        self.fileManager = fileManager
    }

    func save(asset: CapturedAsset, lookName: String?, shadeIDs: [String]) async throws -> SavedCapture {
        if ProcessInfo.processInfo.shouldForceSaveFailure {
            throw CaptureServiceError.debugForcedFailure
        }

        let id = UUID()
        let directory = try captureDirectory()
        let fileURL: URL
        let kind: SavedCapture.Kind

        switch asset {
        case .photo(let image):
            fileURL = directory.appendingPathComponent("\(id.uuidString).jpg")
            guard let data = image.jpegData(compressionQuality: 0.92) else {
                throw CaptureServiceError.jpegEncodingFailed
            }

            try data.write(to: fileURL, options: .atomic)
            kind = .photo

        case .video(let sourceURL):
            guard fileManager.fileExists(atPath: sourceURL.path) else {
                throw CaptureServiceError.videoFileMissing(sourceURL.path)
            }

            fileURL = directory.appendingPathComponent("\(id.uuidString).mp4")
            try fileManager.copyItem(at: sourceURL, to: fileURL)
            kind = .video
        }

        let record = SavedCapture(
            id: id,
            mediaPath: fileURL.lastPathComponent,
            kindRaw: kind.rawValue,
            appliedLookID: lookName,
            appliedShadesJSON: try encodedShadeIDs(shadeIDs),
            name: lookName ?? "Custom mix"
        )

        modelContext.insert(record)
        try modelContext.save()
        return record
    }

    private func captureDirectory() throws -> URL {
        let directory = URL.documentsURL.appendingPathComponent("captures", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private func encodedShadeIDs(_ shadeIDs: [String]) throws -> String {
        let data = try JSONEncoder().encode(shadeIDs.sorted())
        guard let encoded = String(bytes: data, encoding: .utf8) else {
            throw CaptureServiceError.shadeEncodingFailed
        }
        return encoded
    }
}

/// Capture persistence failures.
public enum CaptureServiceError: LocalizedError {
    /// JPEG encoding failed.
    case jpegEncodingFailed
    /// DeepAR reported a video file that does not exist.
    case videoFileMissing(String)
    /// Debug-only forced save failure.
    case debugForcedFailure
    /// Shade metadata could not be encoded.
    case shadeEncodingFailed

    /// Human-readable diagnostic text.
    public var errorDescription: String? {
        switch self {
        case .jpegEncodingFailed:
            "JPEG encoding failed"
        case .videoFileMissing(let path):
            "Video file missing: \(path)"
        case .debugForcedFailure:
            "Debug forced save failure"
        case .shadeEncodingFailed:
            "Shade metadata encoding failed"
        }
    }
}

private extension ProcessInfo {
    var shouldForceSaveFailure: Bool {
        #if DEBUG
        arguments.contains("-GRWMDebugSaveFail")
        #else
        false
        #endif
    }
}
