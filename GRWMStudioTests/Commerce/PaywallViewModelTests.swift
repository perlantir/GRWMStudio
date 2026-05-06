@testable import GRWMStudio
import XCTest

@MainActor
final class PaywallViewModelTests: XCTestCase {
    func testDefaultInitializerStartsWithKidsSafeFallbackState() {
        let viewModel = PaywallViewModel()

        XCTAssertEqual(viewModel.phase, .loading)
        XCTAssertEqual(viewModel.displayPrice, "$14.99")
        XCTAssertNil(viewModel.product)
    }

    func testInitialStateUsesFallbackPrice() {
        let viewModel = PaywallViewModel(productLoader: { nil }, restoreHandler: { false })

        XCTAssertEqual(viewModel.phase, .loading)
        XCTAssertEqual(viewModel.displayPrice, "$14.99")
        XCTAssertNil(viewModel.product)
    }

    func testLoadProductsSuccessSetsReadyPriceAndProduct() async {
        let viewModel = PaywallViewModel(productLoader: { Self.product(price: "$9.99", outcome: .success) })

        await viewModel.loadProducts()

        XCTAssertEqual(viewModel.phase, .ready)
        XCTAssertEqual(viewModel.displayPrice, "$9.99")
        XCTAssertNotNil(viewModel.product)
    }

    func testLoadProductsMissingProductShowsStoreUnavailable() async {
        let viewModel = PaywallViewModel(productLoader: { nil })

        await viewModel.loadProducts()

        XCTAssertEqual(viewModel.phase, .error(L10n.string("paywall.error.store_unavailable")))
    }

    func testLoadProductsFailureShowsStoreUnavailable() async {
        let viewModel = PaywallViewModel(productLoader: { throw StubError() })

        await viewModel.loadProducts()

        XCTAssertEqual(viewModel.phase, .error(L10n.string("paywall.error.store_unavailable")))
    }

    func testPurchaseAutoloadsProductAndSucceeds() async {
        let viewModel = PaywallViewModel(productLoader: { Self.product(price: "$7.99", outcome: .success) })

        await viewModel.purchase()

        XCTAssertEqual(viewModel.phase, .success)
        XCTAssertEqual(viewModel.displayPrice, "$7.99")
    }

    func testPurchaseUserCancelledReturnsReady() async {
        let viewModel = PaywallViewModel(productLoader: { Self.product(outcome: .userCancelled) })

        await viewModel.purchase()

        XCTAssertEqual(viewModel.phase, .ready)
    }

    func testPurchasePendingShowsPendingError() async {
        let viewModel = PaywallViewModel(productLoader: { Self.product(outcome: .pending) })

        await viewModel.purchase()

        XCTAssertEqual(viewModel.phase, .error(L10n.string("paywall.error.pending")))
    }

    func testPurchaseUnverifiedShowsUnverifiedError() async {
        let viewModel = PaywallViewModel(productLoader: { Self.product(outcome: .unverified) })

        await viewModel.purchase()

        XCTAssertEqual(viewModel.phase, .error(L10n.string("paywall.error.unverified")))
    }

    func testPurchaseThrowingProductShowsPurchaseFailed() async {
        let viewModel = PaywallViewModel(
            productLoader: {
                PaywallViewModel.StoreProduct(displayPrice: "$9.99") {
                    throw StubError()
                }
            }
        )

        await viewModel.purchase()

        XCTAssertEqual(viewModel.phase, .error(L10n.string("paywall.error.purchase_failed")))
    }

    func testRestoreSuccessAndMissingStates() async {
        let success = PaywallViewModel(productLoader: { nil }, restoreHandler: { true })
        let missing = PaywallViewModel(productLoader: { nil }, restoreHandler: { false })

        await success.restore()
        await missing.restore()

        XCTAssertEqual(success.phase, .success)
        XCTAssertEqual(missing.phase, .error(L10n.string("paywall.error.restore_missing")))
    }

    func testRestoreFailureShowsUnavailable() async {
        let viewModel = PaywallViewModel(productLoader: { nil }, restoreHandler: { throw StubError() })

        await viewModel.restore()

        XCTAssertEqual(viewModel.phase, .error(L10n.string("paywall.error.restore_unavailable")))
    }

    private static func product(
        price: String = "$9.99",
        outcome: PaywallViewModel.PurchaseOutcome
    ) -> PaywallViewModel.StoreProduct {
        PaywallViewModel.StoreProduct(displayPrice: price) {
            outcome
        }
    }
}

private struct StubError: Error {}
