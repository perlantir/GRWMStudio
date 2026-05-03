@testable import GRWMStudio
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

    private func testImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 8, height: 8)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 8, height: 8))
        }
    }
}
