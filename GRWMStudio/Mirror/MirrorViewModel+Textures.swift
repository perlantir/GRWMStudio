import Foundation
import UIKit

extension MirrorViewModel {
    func image(named assetName: String) async -> UIImage? {
        await effectTextureCache.image(for: assetName) { [assetName] in
            await Self.loadTextureImageOnBackground(named: assetName)
        }
    }

    private nonisolated static func loadTextureImageOnBackground(named assetName: String) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                continuation.resume(returning: loadTextureImage(named: assetName))
            }
        }
    }

    private nonisolated static func loadTextureImage(named assetName: String) -> UIImage? {
        if let image = UIImage(named: assetName) {
            return image
        }

        let resourceName = (assetName as NSString).deletingPathExtension
        let resourceExtension = (assetName as NSString).pathExtension.isEmpty ? "png" : (assetName as NSString).pathExtension

        for subdirectory in ["Effects/luts", "Effects/textures"] {
            if let url = Bundle.main.url(
                forResource: resourceName,
                withExtension: resourceExtension,
                subdirectory: subdirectory
            ),
                let image = UIImage(contentsOfFile: url.path) {
                return image
            }
        }

        return nil
    }
}
