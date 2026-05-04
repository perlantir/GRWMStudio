import UIKit

enum CapturedAsset {
    case photo(UIImage)
    case video(URL)

    var isVideo: Bool {
        if case .video = self {
            return true
        }

        return false
    }
}
