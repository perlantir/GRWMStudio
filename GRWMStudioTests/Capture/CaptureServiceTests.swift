@testable import GRWMStudio
import SwiftData
import UIKit
import XCTest

@MainActor
final class CaptureServiceTests: XCTestCase {
    func testDocumentsCapturesURLCreatesDirectory() throws {
        let url = URL.documentsCapturesURL
        var isDirectory: ObjCBool = false

        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)

        XCTAssertTrue(exists)
        XCTAssertTrue(isDirectory.boolValue)
    }

    func testWriteImageCreatesJPEGFile() throws {
        let image = testImage()

        let url = try CaptureService.writeImage(image)
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertEqual(url.pathExtension, "jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertGreaterThan((try Data(contentsOf: url)).count, 0)
    }

    func testMoveVideoCreatesMP4Capture() throws {
        let sourceURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).mp4")
        try Data([0, 1, 2, 3]).write(to: sourceURL)

        let destinationURL = try CaptureService.moveVideo(from: sourceURL.path)
        defer { try? FileManager.default.removeItem(at: destinationURL) }

        XCTAssertEqual(destinationURL.pathExtension, "mp4")
        XCTAssertFalse(FileManager.default.fileExists(atPath: sourceURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: destinationURL.path))
    }

    func testMoveVideoToTemporaryVideoPreservesContainerExtension() throws {
        let sourceURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).mov")
        try Data([0, 1, 2, 3]).write(to: sourceURL)

        let destinationURL = try CaptureService.moveVideoToTemporaryVideo(from: sourceURL.path)
        defer { try? FileManager.default.removeItem(at: destinationURL) }

        XCTAssertEqual(destinationURL.pathExtension, "mov")
        XCTAssertTrue(destinationURL.path.hasPrefix(FileManager.default.temporaryDirectory.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: sourceURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: destinationURL.path))
    }

    func testSavePhotoCreatesJPEGFileAndSwiftDataRecord() async throws {
        let container = try makeInMemoryContainer()
        let service = CaptureSaveService(container.mainContext)

        let record = try await service.save(
            asset: .photo(testImage()),
            lookName: "Sunday Best",
            shadeIDs: ["lip.classic-red", "cheek.pink"]
        )
        let fileURL = URL.documentsCapturesURL.appendingPathComponent(record.mediaPath)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        XCTAssertEqual(record.kind, .photo)
        XCTAssertEqual(record.name, "Sunday Best")
        XCTAssertEqual(record.appliedLookID, "Sunday Best")
        XCTAssertEqual(record.mediaPath, record.id.uuidString + ".jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        XCTAssertGreaterThan((try Data(contentsOf: fileURL)).count, 0)
        XCTAssertEqual(try decodedShadeIDs(from: record), ["cheek.pink", "lip.classic-red"])

        let records = try container.mainContext.fetch(FetchDescriptor<SavedCapture>())
        XCTAssertEqual(records.map(\.id), [record.id])
    }

    func testSaveVideoCopiesFileAndSwiftDataRecord() async throws {
        let container = try makeInMemoryContainer()
        let service = CaptureSaveService(container.mainContext)
        let sourceURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).mp4")
        try Data([0, 1, 2, 3, 4]).write(to: sourceURL)
        defer { try? FileManager.default.removeItem(at: sourceURL) }

        let record = try await service.save(asset: .video(sourceURL), lookName: nil, shadeIDs: ["brow.black"])
        let fileURL = URL.documentsCapturesURL.appendingPathComponent(record.mediaPath)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        XCTAssertEqual(record.kind, .video)
        XCTAssertEqual(record.name, "Custom mix")
        XCTAssertEqual(record.mediaPath, record.id.uuidString + ".mp4")
        XCTAssertTrue(FileManager.default.fileExists(atPath: sourceURL.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        XCTAssertEqual(try Data(contentsOf: fileURL), Data([0, 1, 2, 3, 4]))
        XCTAssertEqual(try decodedShadeIDs(from: record), ["brow.black"])
    }

    func testSaveVideoMissingSourceThrows() async throws {
        let container = try makeInMemoryContainer()
        let service = CaptureSaveService(container.mainContext)
        let missingURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID()).mp4")

        do {
            _ = try await service.save(asset: .video(missingURL), lookName: nil, shadeIDs: [])
            XCTFail("Expected missing video to throw")
        } catch CaptureServiceError.videoFileMissing(let path) {
            XCTAssertEqual(path, missingURL.path)
        }

        let records = try container.mainContext.fetch(FetchDescriptor<SavedCapture>())
        XCTAssertTrue(records.isEmpty)
    }

    private func testImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
    }

    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            SavedCapture.self,
            ProfileRecord.self,
            FavoriteLook.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: configuration)
    }

    private func decodedShadeIDs(from record: SavedCapture) throws -> [String] {
        try JSONDecoder().decode([String].self, from: Data(record.appliedShadesJSON.utf8))
    }
}
