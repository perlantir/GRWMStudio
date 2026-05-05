import Foundation
import Observation
import OSLog
import StoreKit

@MainActor
@Observable
final class ProEntitlements {
    static let cacheKey = "dh.isPro.cached"

    private let defaults: UserDefaults
    private(set) var isPro: Bool
    private var transactionListener: Task<Void, Never>?

    init(defaults: UserDefaults = .standard, autoRefresh: Bool = true) {
        self.defaults = defaults
        isPro = defaults.bool(forKey: Self.cacheKey)

        if autoRefresh {
            startListening()
            Task {
                await refresh()
            }
        }
    }

    func refresh() async {
        var authoritativePro = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == StoreIDs.proLifetime,
               transaction.revocationDate == nil {
                authoritativePro = true
            }
        }

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
        transactionListener = Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    if transaction.productID == StoreIDs.proLifetime {
                        await MainActor.run {
                            self.isPro = transaction.revocationDate == nil
                            self.defaults.set(self.isPro, forKey: Self.cacheKey)
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }
}
