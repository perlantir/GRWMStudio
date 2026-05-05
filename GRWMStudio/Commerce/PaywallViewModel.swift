import Foundation
import Observation
import OSLog
import StoreKit

@MainActor
@Observable
final class PaywallViewModel {
    enum Phase: Equatable {
        case loading
        case ready
        case purchasing
        case success
        case restoring
        case error(String)
    }

    private(set) var phase: Phase = .loading
    private(set) var displayPrice = "$14.99"
    private(set) var product: Product?

    func loadProducts() async {
        if case .purchasing = phase { return }
        if case .restoring = phase { return }

        phase = .loading
        do {
            let products = try await Product.products(for: [StoreIDs.proLifetime])
            guard let product = products.first else {
                phase = .error(L10n.string("paywall.error.store_unavailable"))
                return
            }
            self.product = product
            displayPrice = product.displayPrice
            phase = .ready
        } catch {
            Logger.storeKit.error("Product load failed: \(error.localizedDescription, privacy: .public)")
            phase = .error(L10n.string("paywall.error.store_unavailable"))
        }
    }

    func purchase() async {
        if case .purchasing = phase { return }
        if case .restoring = phase { return }

        if product == nil {
            await loadProducts()
        }
        guard let product else { return }

        phase = .purchasing
        do {
            let result = try await product.purchase()
            await handlePurchaseResult(result)
        } catch {
            Logger.storeKit.error("Purchase failed: \(error.localizedDescription, privacy: .public)")
            phase = .error(L10n.string("paywall.error.purchase_failed"))
        }
    }

    func restore() async {
        if case .restoring = phase { return }
        if case .purchasing = phase { return }

        phase = .restoring
        do {
            try await AppStore.sync()
            await ProEntitlementsHolder.shared.entitlements.refresh()
            if ProEntitlementsHolder.shared.entitlements.isPro {
                phase = .success
            } else {
                phase = .error(L10n.string("paywall.error.restore_missing"))
            }
        } catch {
            Logger.storeKit.error("Restore failed: \(error.localizedDescription, privacy: .public)")
            phase = .error(L10n.string("paywall.error.restore_unavailable"))
        }
    }

    private func handlePurchaseResult(_ result: Product.PurchaseResult) async {
        switch result {
        case .success(let verification):
            await handleVerification(verification)
        case .userCancelled:
            phase = .ready
        case .pending:
            phase = .error(L10n.string("paywall.error.pending"))
        @unknown default:
            phase = .error(L10n.string("paywall.error.purchase_failed"))
        }
    }

    private func handleVerification(_ verification: VerificationResult<Transaction>) async {
        switch verification {
        case .verified(let transaction):
            await transaction.finish()
            await ProEntitlementsHolder.shared.entitlements.refresh()
            phase = .success
        case .unverified:
            phase = .error(L10n.string("paywall.error.unverified"))
        }
    }
}
