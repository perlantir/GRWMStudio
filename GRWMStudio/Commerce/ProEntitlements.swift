import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class ProEntitlements {
    static let cacheKey = "dh.isPro.cached"

    private let defaults: UserDefaults
    private let store: any ProPurchaseStateStoring
    private(set) var isPro: Bool
    private var transactionListener: Task<Void, Never>?

    init(
        defaults: UserDefaults = .standard,
        autoRefresh: Bool = true,
        store: any ProPurchaseStateStoring = StoreKitPurchaseStateStore()
    ) {
        self.defaults = defaults
        self.store = store
        isPro = defaults.bool(forKey: Self.cacheKey)

        if autoRefresh {
            startListening()
            Task {
                await refresh()
            }
        }
    }

    func refresh() async {
        let authoritativePro = await store.currentIsPro()

        let cached = isPro
        if cached != authoritativePro {
            if cached, !authoritativePro {
                Logger.storeKit.warning("Cached Pro entitlement contradicted by StoreKit; clearing cached state")
            } else if !cached, authoritativePro {
                Logger.storeKit.info("StoreKit restored Pro entitlement over cached false state")
            }
        }

        isPro = authoritativePro
        defaults.set(authoritativePro, forKey: Self.cacheKey)
    }

    private func startListening() {
        let updates = store.proPurchaseUpdates()
        transactionListener = Task { [weak self] in
            for await isPro in updates {
                guard let self else { return }
                await MainActor.run {
                    self.isPro = isPro
                    self.defaults.set(isPro, forKey: Self.cacheKey)
                }
            }
        }
    }
}

@MainActor
protocol ProPurchaseStateStoring {
    func currentIsPro() async -> Bool
    func proPurchaseUpdates() -> AsyncStream<Bool>
}
