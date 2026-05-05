import SwiftUI
import UIKit

struct AsyncBundleImage<Placeholder: View>: View {
    let assetName: String
    let subdirectory: String?
    let placeholder: Placeholder

    @State private var image: UIImage?

    init(
        assetName: String,
        subdirectory: String? = nil,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self.assetName = assetName
        self.subdirectory = subdirectory
        self.placeholder = placeholder()
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
            }
        }
        .task(id: taskID) {
            guard image == nil else {
                return
            }
            image = await BundleImageLoader.loadImage(named: assetName, subdirectory: subdirectory)
        }
    }

    private var taskID: String {
        "\(subdirectory ?? "bundle"):\(assetName)"
    }
}

private enum BundleImageLoader {
    static func loadImage(named assetName: String, subdirectory: String?) async -> UIImage? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                continuation.resume(returning: bundledImage(named: assetName, subdirectory: subdirectory))
            }
        }
    }

    private static func bundledImage(named assetName: String, subdirectory: String?) -> UIImage? {
        if let image = UIImage(named: assetName) {
            return image
        }

        let resourceName = (assetName as NSString).deletingPathExtension
        let pathExtension = (assetName as NSString).pathExtension
        let resourceExtension = pathExtension.isEmpty ? "png" : pathExtension

        guard let url = Bundle.main.url(
            forResource: resourceName,
            withExtension: resourceExtension,
            subdirectory: subdirectory
        ) else {
            return nil
        }

        return UIImage(contentsOfFile: url.path)
    }
}
