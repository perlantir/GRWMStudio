import Foundation
import StoreKit

extension PaywallViewModel {
    static func loadLiveProduct() async throws -> StoreProduct? {
        let products = try await Product.products(for: [StoreIDs.proLifetime])
        guard let product = products.first else {
            return nil
        }

        return StoreProduct(displayPrice: product.displayPrice) {
            let result = try await product.purchase()
            return await purchaseOutcome(from: result)
        }
    }

    static func restoreLivePurchase() async throws -> Bool {
        try await AppStore.sync()
        await ProEntitlementsHolder.shared.entitlements.refresh()
        return ProEntitlementsHolder.shared.entitlements.isPro
    }

    private static func purchaseOutcome(from result: Product.PurchaseResult) async -> PurchaseOutcome {
        switch result {
        case .success(let verification):
            return await purchaseOutcome(from: verification)
        case .userCancelled:
            return .userCancelled
        case .pending:
            return .pending
        @unknown default:
            return .unverified
        }
    }

    private static func purchaseOutcome(from verification: VerificationResult<Transaction>) async -> PurchaseOutcome {
        switch verification {
        case .verified(let transaction):
            await transaction.finish()
            await ProEntitlementsHolder.shared.entitlements.refresh()
            return .success
        case .unverified:
            return .unverified
        }
    }
}
