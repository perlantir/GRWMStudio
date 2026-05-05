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
            throw CaptureServiceError.contextFailed
        }

        let captureCount = try modelContext.fetchCount(FetchDescriptor<SavedCapture>())
        if captureCount >= 50 {
            throw CaptureServiceError.lockerAtLimit
        }

        let id = UUID()
        let directory = try captureDirectory()
        let storedFile = try writeAssetFile(asset, id: id, directory: directory)

        let record = SavedCapture(
            id: id,
            mediaPath: storedFile.url.lastPathComponent,
            kindRaw: storedFile.kind.rawValue,
            appliedLookID: lookName,
            appliedShadesJSON: try encodedShadeIDs(shadeIDs),
            name: lookName ?? "Custom mix"
        )

        try persist(record)
        return record
    }

    private func writeAssetFile(
        _ asset: CapturedAsset,
        id: UUID,
        directory: URL
    ) throws -> (url: URL, kind: SavedCapture.Kind) {
        switch asset {
        case .photo(let image):
            let fileURL = directory.appendingPathComponent("\(id.uuidString).jpg")
            guard let data = image.jpegData(compressionQuality: 0.92) else {
                throw CaptureServiceError.jpegEncodingFailed
            }
            try write(data, to: fileURL)
            return (fileURL, .photo)

        case .video(let sourceURL):
            guard fileManager.fileExists(atPath: sourceURL.path) else {
                throw CaptureServiceError.videoFileMissing(sourceURL.path)
            }

            let fileURL = directory.appendingPathComponent("\(id.uuidString).mp4")
            try copyItem(at: sourceURL, to: fileURL)
            return (fileURL, .video)
        }
    }

    private func write(_ data: Data, to fileURL: URL) throws {
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch let error as CocoaError where error.code == .fileWriteOutOfSpace {
            throw CaptureServiceError.capacityExceeded
        } catch {
            throw CaptureServiceError.copyFailed
        }
    }

    private func copyItem(at sourceURL: URL, to destinationURL: URL) throws {
        do {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        } catch let error as CocoaError where error.code == .fileWriteOutOfSpace {
            throw CaptureServiceError.capacityExceeded
        } catch {
            throw CaptureServiceError.copyFailed
        }
    }

    private func persist(_ record: SavedCapture) throws {
        modelContext.insert(record)
        updateProfileActivity()
        do {
            try modelContext.save()
        } catch let error as CocoaError where error.code == .fileWriteOutOfSpace {
            throw CaptureServiceError.capacityExceeded
        } catch {
            throw CaptureServiceError.contextFailed
        }
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

    private func updateProfileActivity() {
        let descriptor = FetchDescriptor<ProfileRecord>()
        let profile = (try? modelContext.fetch(descriptor).first) ?? {
            let record = ProfileRecord.makeDefault()
            modelContext.insert(record)
            return record
        }()

        profile.recordActivity(today: .now)
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
    /// The local locker is full.
    case lockerAtLimit
    /// The media file could not be copied into the locker.
    case copyFailed
    /// SwiftData could not persist the saved capture record.
    case contextFailed
    /// The device ran out of space while writing.
    case capacityExceeded

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
        case .lockerAtLimit:
            "Locker is full"
        case .copyFailed:
            "Capture copy failed"
        case .contextFailed:
            "Capture persistence failed"
        case .capacityExceeded:
            "Device is out of storage"
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
