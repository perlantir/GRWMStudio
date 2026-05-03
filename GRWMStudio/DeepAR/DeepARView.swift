import Observation
import SwiftUI
import UIKit

/// SwiftUI host for DeepAR's UIKit rendering view.
@MainActor
struct DeepARView: UIViewRepresentable {
    /// Controller that owns the DeepAR SDK view.
    let controller: DeepARController

    func makeUIView(context: Context) -> DeepARContainerView {
        DeepARContainerView(controller: controller)
    }

    func updateUIView(_ uiView: DeepARContainerView, context: Context) {
        uiView.refresh()
    }
}

/// UIKit container that swaps between a branded placeholder and the live DeepAR view.
@MainActor
final class DeepARContainerView: UIView {
    private let controller: DeepARController
    private weak var hostedARView: UIView?
    private let placeholder = UIView()
    private let mirrorPlate = UIView()
    private let placeholderLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    init(controller: DeepARController) {
        self.controller = controller
        super.init(frame: .zero)

        configureContainer()
        configurePlaceholder()
        configureMirrorPlate()
        configureLabel()
        configureActivityIndicator()
        refresh()
        observeControllerState()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    /// Refreshes the hosted view for the controller's current state.
    func refresh() {
        switch controller.state {
        case .uninitialized:
            showPlaceholder(text: Self.magicMirrorText, isLoading: false)
        case .initializing:
            showPlaceholder(text: Self.warmingUpText, isLoading: true)
        case .ready:
            showReadyState()
        case .failed:
            showPlaceholder(text: Self.errorText, isLoading: false)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        hostedARView?.frame = bounds
    }

    private func configureContainer() {
        accessibilityIdentifier = "deepar-view-container"
        backgroundColor = UIColor(DH.pinkPaper)
        clipsToBounds = true
        layer.cornerRadius = DH.Radius.viewportInner
        layer.cornerCurve = .continuous
    }

    private func configurePlaceholder() {
        placeholder.accessibilityIdentifier = "deepar-placeholder"
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        placeholder.backgroundColor = .clear
        addSubview(placeholder)
        NSLayoutConstraint.activate([
            placeholder.topAnchor.constraint(equalTo: topAnchor),
            placeholder.leadingAnchor.constraint(equalTo: leadingAnchor),
            placeholder.trailingAnchor.constraint(equalTo: trailingAnchor),
            placeholder.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func configureMirrorPlate() {
        mirrorPlate.translatesAutoresizingMaskIntoConstraints = false
        mirrorPlate.backgroundColor = UIColor(DH.cream)
        mirrorPlate.layer.cornerRadius = DH.Radius.bigCard
        mirrorPlate.layer.cornerCurve = .continuous
        mirrorPlate.layer.borderColor = UIColor(DH.pinkDeep.opacity(0.18)).cgColor
        mirrorPlate.layer.borderWidth = 2
        placeholder.addSubview(mirrorPlate)
        NSLayoutConstraint.activate([
            mirrorPlate.centerXAnchor.constraint(equalTo: placeholder.centerXAnchor),
            mirrorPlate.centerYAnchor.constraint(equalTo: placeholder.centerYAnchor),
            mirrorPlate.widthAnchor.constraint(lessThanOrEqualTo: placeholder.widthAnchor, multiplier: 0.72),
            mirrorPlate.widthAnchor.constraint(greaterThanOrEqualToConstant: 184),
            mirrorPlate.heightAnchor.constraint(equalToConstant: 118)
        ])
    }

    private func configureLabel() {
        placeholderLabel.accessibilityIdentifier = "deepar-placeholder-label"
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = UIColor(DH.pinkDeep)
        placeholderLabel.font = Self.labelFont(size: 24)
        placeholderLabel.adjustsFontForContentSizeCategory = false
        placeholderLabel.numberOfLines = 2
        mirrorPlate.addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: mirrorPlate.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: mirrorPlate.centerYAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(greaterThanOrEqualTo: mirrorPlate.leadingAnchor, constant: 18),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: mirrorPlate.trailingAnchor, constant: -18)
        ])
    }

    private func configureActivityIndicator() {
        activityIndicator.accessibilityIdentifier = "deepar-placeholder-spinner"
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(DH.pinkDeep)
        mirrorPlate.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: mirrorPlate.centerXAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: placeholderLabel.topAnchor, constant: -10)
        ])
    }

    private func showReadyState() {
        #if targetEnvironment(simulator)
        showPlaceholder(text: Self.magicMirrorText, isLoading: false)
        #else
        activityIndicator.stopAnimating()
        placeholder.isHidden = true
        mountARViewIfNeeded()
        #endif
    }

    private func showPlaceholder(text: String, isLoading: Bool) {
        placeholderLabel.text = text
        placeholder.isHidden = false
        hostedARView?.removeFromSuperview()
        hostedARView = nil

        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func mountARViewIfNeeded() {
        guard hostedARView == nil, let arView = controller.arView else {
            return
        }

        arView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(arView, belowSubview: placeholder)
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: topAnchor),
            arView.leadingAnchor.constraint(equalTo: leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        hostedARView = arView
    }

    private func observeControllerState() {
        withObservationTracking {
            _ = controller.state
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.refresh()
                self?.observeControllerState()
            }
        }
    }

    private static let magicMirrorText = "✨ Magic Mirror"
    private static let warmingUpText = "Warming up the magic..."
    private static let errorText = "Mirror needs a restart"

    private static func labelFont(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Fredoka-Bold", size: size) else {
            preconditionFailure("Fredoka-Bold font is missing from the app bundle.")
        }
        return font
    }
}

#Preview("DeepAR Placeholder") {
    DeepARView(controller: DeepARController())
        .frame(width: 350, height: 460)
        .padding()
        .background(DH.pinkPaper)
}

#if DEBUG
struct DeepARViewDebugScreen: View {
    enum Mode {
        case placeholder
        case initializing
    }

    @State private var controller = DeepARController()
    let mode: Mode

    init(mode: Mode = .placeholder) {
        self.mode = mode
        let initialController: DeepARController = switch mode {
        case .placeholder:
            DeepARController()
        case .initializing:
            DeepARController(
                clientFactory: { DeepARViewDebugClient(autoInitialize: false) },
                bootstrapTimeout: .seconds(60)
            )
        }
        _controller = State(initialValue: initialController)
    }

    var body: some View {
        ZStack {
            DHWallpaperStripes(stripeWidth: 30, secondaryStripeWidth: 2)
            DeepARView(controller: controller)
                .frame(width: 340, height: 440)
                .chunkyShadow(.lg(), shape: RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
        }
        .ignoresSafeArea()
        .preferredColorScheme(.light)
        .task {
            guard mode == .initializing, controller.state == .uninitialized else {
                return
            }
            try? await controller.bootstrap(licenseKey: "debug-license")
        }
    }
}

@MainActor
private final class DeepARViewDebugClient: DeepARClient {
    private let autoInitialize: Bool
    private weak var delegate: DeepARDelegateProxy?

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
#endif
