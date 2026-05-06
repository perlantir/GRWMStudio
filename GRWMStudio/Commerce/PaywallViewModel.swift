import Foundation
import Observation
import OSLog

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

    enum PurchaseOutcome: Equatable {
        case success
        case userCancelled
        case pending
        case unverified
    }

    struct StoreProduct {
        let displayPrice: String
        let purchase: @MainActor () async throws -> PurchaseOutcome
    }

    private(set) var phase: Phase = .loading
    private(set) var displayPrice = "$14.99"
    private(set) var product: StoreProduct?

    private let productLoader: @MainActor () async throws -> StoreProduct?
    private let restoreHandler: @MainActor () async throws -> Bool

    init(
        productLoader: @escaping @MainActor () async throws -> StoreProduct? = PaywallViewModel.loadLiveProduct,
        restoreHandler: @escaping @MainActor () async throws -> Bool = PaywallViewModel.restoreLivePurchase
    ) {
        self.productLoader = productLoader
        self.restoreHandler = restoreHandler
    }

    func loadProducts() async {
        if case .purchasing = phase { return }
        if case .restoring = phase { return }

        phase = .loading
        do {
            guard let product = try await productLoader() else {
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
            handlePurchaseResult(result)
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
            if try await restoreHandler() {
                phase = .success
            } else {
                phase = .error(L10n.string("paywall.error.restore_missing"))
            }
        } catch {
            Logger.storeKit.error("Restore failed: \(error.localizedDescription, privacy: .public)")
            phase = .error(L10n.string("paywall.error.restore_unavailable"))
        }
    }

    private func handlePurchaseResult(_ result: PurchaseOutcome) {
        switch result {
        case .success:
            phase = .success
        case .userCancelled:
            phase = .ready
        case .pending:
            phase = .error(L10n.string("paywall.error.pending"))
        case .unverified:
            phase = .error(L10n.string("paywall.error.unverified"))
        }
    }
}
