import Foundation

enum ParentGateIntent: Hashable, Identifiable {
    case paywall(source: RootCoordinator.PaywallSource)
    case manageSubscription
    case privacyDeepLink(URL)
    case saveToPhotos
    case deleteAllData

    var id: String {
        switch self {
        case .paywall(let source):
            "paywall-\(source)"
        case .manageSubscription:
            "manage-subscription"
        case .privacyDeepLink(let url):
            "privacy-\(url.absoluteString)"
        case .saveToPhotos:
            "save-to-photos"
        case .deleteAllData:
            "delete-all-data"
        }
    }
}
