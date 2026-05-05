import Foundation

@MainActor
final class ProEntitlementsHolder {
    static let shared = ProEntitlementsHolder()

    let entitlements = ProEntitlements()

    private init() {}
}
