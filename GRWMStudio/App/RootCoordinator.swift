import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class RootCoordinator {
    enum Route: Hashable {
        case onboardingSplash
        case onboardingWelcome
        case onboardingParentInfo
        case onboardingPermissions
        case onboardingPermissionsDenied
        case app
        case preview
        case parentalGate(reason: GateReason)
        case paywall(source: PaywallSource)
    }

    enum Overlay: Hashable {
        case preview
        case savedConfetti
    }

    enum GateReason: Hashable {
        case paywall
        case externalLink(URL)
        case deleteData
    }

    enum PaywallSource: Hashable, Identifiable {
        case proShade
        case lockerLimit
        case longRecording
        case settings

        var id: String {
            switch self {
            case .proShade:
                "pro-shade"
            case .lockerLimit:
                "locker-limit"
            case .longRecording:
                "long-recording"
            case .settings:
                "settings"
            }
        }
    }

    var route: Route = .onboardingSplash
    var previewAsset: CapturedAsset?
    var previewLookName: String?
    var previewShadeIDs: [String] = []
    var presentedParentGate: ParentGateIntent?
    var presentedPaywallSource: PaywallSource?
    var presentedError: ErrorVariant?
    var toastMessage: String?
    private(set) var overlay: Overlay?
    @ObservationIgnored private let openURL: @MainActor (URL, @escaping @Sendable (Bool) -> Void) -> Void
    @ObservationIgnored private let notificationCenter: NotificationCenter
    @ObservationIgnored private let currentDate: @MainActor () -> Date
    @ObservationIgnored private var lastDeepLinkAt: Date = .distantPast
    @ObservationIgnored private var pendingAuthorizedAction: (@MainActor () async -> Void)?
    @ObservationIgnored private var toastTask: Task<Void, Never>?

    init(
        openURL: @escaping @MainActor (URL, @escaping @Sendable (Bool) -> Void) -> Void = { url, completion in
            UIApplication.shared.open(url, options: [:], completionHandler: completion)
        },
        notificationCenter: NotificationCenter = .default,
        currentDate: @escaping @MainActor () -> Date = Date.init
    ) {
        self.openURL = openURL
        self.notificationCenter = notificationCenter
        self.currentDate = currentDate
    }

    func advanceFromSplash() {
        route = .onboardingWelcome
    }

    func showWelcome() {
        route = .onboardingWelcome
    }

    func showParentInfo() {
        route = .onboardingParentInfo
    }

    func showPermissions() {
        route = .onboardingPermissions
    }

    func showPermissionsDenied() {
        route = .onboardingPermissionsDenied
    }

    func enterApp() {
        route = .app
    }

    func completeOnboarding(env: AppEnvironment) {
        env.onboarding.hasCompletedOnboarding = true
        enterApp()
    }

    func presentParentalGate(reason: GateReason) {
        route = .parentalGate(reason: reason)
    }

    func presentPaywall(source: PaywallSource) {
        presentedPaywallSource = source
    }

    func presentError(_ variant: ErrorVariant) {
        presentedError = variant
    }

    func dismissError() {
        presentedError = nil
    }

    func showPreview(asset: CapturedAsset, lookName: String? = nil, shadeIDs: [String] = []) {
        previewAsset = asset
        previewLookName = lookName
        previewShadeIDs = shadeIDs
        overlay = .preview
    }

    func dismissPreview() {
        previewAsset = nil
        previewLookName = nil
        previewShadeIDs = []
        if overlay == .preview {
            overlay = nil
        } else {
            route = .app
        }
    }

    func dismissPreviewSaved() {
        previewAsset = nil
        previewLookName = nil
        previewShadeIDs = []
        overlay = .savedConfetti
    }

    func finishPreviewSaved() {
        if overlay == .savedConfetti {
            overlay = nil
        }
        if route == .preview {
            route = .app
        }
    }

    func startParentGate(
        intent: ParentGateIntent,
        authorizedAction: (@MainActor () async -> Void)? = nil
    ) {
        pendingAuthorizedAction = authorizedAction
        presentedParentGate = intent
    }

    func dismissParentGate() {
        presentedParentGate = nil
        pendingAuthorizedAction = nil
    }

    func parentGatePassed(_ intent: ParentGateIntent) {
        presentedParentGate = nil
        switch intent {
        case .paywall(let source):
            Task { @MainActor [weak self] in
                try? await Task.sleep(for: .milliseconds(250))
                self?.presentPaywall(source: source)
            }
        case .manageSubscription:
            openExternalURL(
                PurchaseLinks.managePurchases,
                failureMessage: "Couldn't open the App Store. Try later."
            )
        case .privacyDeepLink(let url):
            pendingAuthorizedAction = nil
            openExternalURL(url, failureMessage: "Couldn't open that link.")
        case .saveToPhotos:
            let action = pendingAuthorizedAction
            pendingAuthorizedAction = nil
            Task { @MainActor in
                await action?()
            }
        case .deleteAllData:
            pendingAuthorizedAction = nil
            notificationCenter.post(name: .deleteAllRequested, object: nil)
        }
    }

    var isPaywallPresented: Bool {
        presentedPaywallSource != nil
    }

    func dismissPaywall() {
        presentedPaywallSource = nil
    }

    func dismissOverlay() {
        overlay = nil
    }

    func showToast(_ message: String, duration: Duration = .seconds(2.4)) {
        toastTask?.cancel()
        toastMessage = message
        toastTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: duration)
            guard let self, self.toastMessage == message else {
                return
            }
            self.toastMessage = nil
        }
    }

    func dismissToast() {
        toastTask?.cancel()
        toastMessage = nil
    }

    private func openExternalURL(_ url: URL, failureMessage: String) {
        let now = currentDate()
        guard now.timeIntervalSince(lastDeepLinkAt) >= 1 else {
            return
        }
        lastDeepLinkAt = now

        openURL(url) { [weak self] opened in
            guard !opened else {
                return
            }
            Task { @MainActor in
                self?.showToast(failureMessage)
            }
        }
    }
}

private struct RootCoordinatorKey: EnvironmentKey {
    static let defaultValue = MainActor.assumeIsolated {
        RootCoordinator()
    }
}

extension EnvironmentValues {
    var rootCoordinator: RootCoordinator {
        get { self[RootCoordinatorKey.self] }
        set { self[RootCoordinatorKey.self] = newValue }
    }
}

extension Notification.Name {
    static let deleteAllRequested = Notification.Name("dh.deleteAllRequested")
}
