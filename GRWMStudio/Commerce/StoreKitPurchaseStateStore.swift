import Foundation
import StoreKit

struct StoreKitPurchaseStateStore: ProPurchaseStateStoring {
    func currentIsPro() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == StoreIDs.proLifetime,
               transaction.revocationDate == nil {
                return true
            }
        }

        return false
    }

    func proPurchaseUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let task = Task {
                for await result in Transaction.updates {
                    if case .verified(let transaction) = result {
                        if transaction.productID == StoreIDs.proLifetime {
                            continuation.yield(transaction.revocationDate == nil)
                        }
                        await transaction.finish()
                    }
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
