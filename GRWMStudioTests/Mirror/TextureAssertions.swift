import UIKit
import XCTest

enum TextureAssertions {
    static func assertTexture(_ textureName: String, matchesSource sourceName: String) throws {
        XCTAssertEqual(
            try textureData(textureName),
            try sourceTextureData(sourceName),
            "\(textureName) must preserve the DeepAR source UV layout from \(sourceName)."
        )
    }

    static func assertTexture(_ textureName: String, doesNotMatchSource sourceName: String) throws {
        XCTAssertNotEqual(
            try textureData(textureName),
            try sourceTextureData(sourceName),
            "\(textureName) is mapped to the wrong DeepAR face region source texture."
        )
    }

    static func textureData(_ filename: String) throws -> Data {
        try Data(contentsOf: repoRoot.appendingPathComponent("GRWMStudio/Resources/Effects/textures/\(filename)"))
    }

    static func sourceTextureData(_ filename: String) throws -> Data {
        try Data(contentsOf: repoRoot.appendingPathComponent(sourceTexturePath(filename)))
    }

    static func imageSize(_ filename: String) throws -> CGSize {
        let image = try textureImage(
            at: repoRoot.appendingPathComponent("GRWMStudio/Resources/Effects/textures/\(filename)")
        )
        return CGSize(width: image.width, height: image.height)
    }

    static func sourceImageSize(_ filename: String) throws -> CGSize {
        let image = try textureImage(at: repoRoot.appendingPathComponent(sourceTexturePath(filename)))
        return CGSize(width: image.width, height: image.height)
    }

    static func alphaBounds(_ filename: String) throws -> CGRect? {
        let image = try textureImage(
            at: repoRoot.appendingPathComponent("GRWMStudio/Resources/Effects/textures/\(filename)")
        )
        let width = image.width
        let height = image.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixels = [UInt8](repeating: 0, count: height * bytesPerRow)
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo
        ) else {
            XCTFail("Could not create bitmap context for \(filename).")
            return nil
        }

        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        return alphaBounds(in: pixels, width: width, height: height, bytesPerRow: bytesPerRow)
    }

    private static func alphaBounds(
        in pixels: [UInt8],
        width: Int,
        height: Int,
        bytesPerRow: Int
    ) -> CGRect? {
        let bytesPerPixel = 4
        var minX = width
        var minY = height
        var maxX = -1
        var maxY = -1

        for yPosition in 0..<height {
            for xPosition in 0..<width {
                let alpha = pixels[(yPosition * bytesPerRow) + (xPosition * bytesPerPixel) + 3]
                guard alpha > 0 else {
                    continue
                }
                minX = min(minX, xPosition)
                minY = min(minY, yPosition)
                maxX = max(maxX, xPosition)
                maxY = max(maxY, yPosition)
            }
        }

        guard maxX >= minX, maxY >= minY else {
            return nil
        }
        return CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
    }

    private static func textureImage(at url: URL) throws -> CGImage {
        let image = try XCTUnwrap(UIImage(contentsOfFile: url.path), "Missing texture image: \(url.path)")
        return try XCTUnwrap(image.cgImage, "Could not decode texture image: \(url.path)")
    }

    private static var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private static func sourceTexturePath(_ filename: String) -> String {
        "GRWMStudio/Resources/Effects/_source/Free.v1.3/baseBeauty.deeparproj/resources/\(filename)"
    }
}
