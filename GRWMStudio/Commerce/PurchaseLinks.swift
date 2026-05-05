import UIKit

enum PurchaseLinks {
    static let managePurchases = requiredURL("https://apps.apple.com/account")
    static let requestRefund = requiredURL("https://reportaproblem.apple.com/")

    @MainActor
    static func openManagePurchases() {
        UIApplication.shared.open(managePurchases)
    }

    @MainActor
    static func openRequestRefund() {
        UIApplication.shared.open(requestRefund)
    }

    private static func requiredURL(_ value: String) -> URL {
        guard let url = URL(string: value) else {
            preconditionFailure("Invalid hardcoded URL: \(value)")
        }
        return url
    }
}
