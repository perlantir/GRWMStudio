import AVFoundation
import UIKit

actor ThumbnailLoader {
    static let shared = ThumbnailLoader()

    private let cache = NSCache<NSString, UIImage>()

    func load(url: URL, kind: SavedCapture.Kind) async -> UIImage? {
        let key = url.path as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let image: UIImage?
        switch kind {
        case .photo:
            image = UIImage(contentsOfFile: url.path)
        case .video:
            image = videoThumbnail(for: url)
        }

        if let image {
            cache.setObject(image, forKey: key)
        }
        return image
    }

    private func videoThumbnail(for url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 600, height: 600)

        let time = CMTime(seconds: 0.3, preferredTimescale: 600)
        guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
