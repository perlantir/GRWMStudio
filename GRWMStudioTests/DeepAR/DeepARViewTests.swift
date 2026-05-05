@testable import GRWMStudio
import UIKit
import XCTest

@MainActor
final class DeepARViewTests: XCTestCase {
    func testUninitializedStateShowsMagicMirrorPlaceholder() {
        let controller = DeepARController()
        let container = DeepARContainerView(controller: controller)

        container.refresh()

        XCTAssertFalse(container.deepARPlaceholder.isHidden)
        XCTAssertEqual(container.deepARPlaceholderLabel.text, "✨ Magic Mirror")
    }

    func testInitializingStateShowsSpinner() async {
        let mock = ViewMockDeepARClient(autoInitialize: false)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let container = DeepARContainerView(controller: controller)
        let bootstrapTask = Task {
            try? await controller.bootstrap(licenseKey: "test-license")
        }

        await Task.yield()
        container.refresh()

        XCTAssertEqual(container.deepARPlaceholderLabel.text, "Warming up the magic...")
        XCTAssertFalse(container.deepARSpinner.isHidden)
        mock.delegate?.didInitialize()
        _ = await bootstrapTask.value
    }

    func testReadyStateKeepsPlaceholderOnSimulator() async throws {
        let mock = ViewMockDeepARClient(autoInitialize: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let container = DeepARContainerView(controller: controller)

        try await controller.bootstrap(licenseKey: "test-license")
        container.refresh()

        XCTAssertFalse(container.deepARPlaceholder.isHidden)
        XCTAssertEqual(container.deepARPlaceholderLabel.text, "✨ Magic Mirror")
    }
}

@MainActor
private final class ViewMockDeepARClient: DeepARClient {
    private let autoInitialize: Bool
    private(set) var delegate: DeepARDelegateProxy?

    init(autoInitialize: Bool) {
        self.autoInitialize = autoInitialize
    }

    func setLicenseKey(_ licenseKey: String) {}

    func setDelegate(_ delegate: DeepARDelegateProxy) {
        self.delegate = delegate
    }

    func createARView(frame: CGRect) -> UIView {
        if autoInitialize {
            Task { @MainActor [weak self] in
                self?.delegate?.didInitialize()
            }
        }
        return UIView(frame: frame)
    }

    func switchEffect(withSlot slot: String, path: String?) {}
}

private extension UIView {
    var deepARPlaceholder: UIView {
        findView(identifier: "deepar-placeholder") ?? UIView()
    }

    var deepARPlaceholderLabel: UILabel {
        findView(identifier: "deepar-placeholder-label") ?? UILabel()
    }

    var deepARSpinner: UIView {
        findView(identifier: "deepar-placeholder-spinner") ?? UIView()
    }

    func findView<ViewType: UIView>(identifier: String) -> ViewType? {
        if accessibilityIdentifier == identifier {
            return self as? ViewType
        }

        for subview in subviews {
            if let match: ViewType = subview.findView(identifier: identifier) {
                return match
            }
        }
        return nil
    }
}
