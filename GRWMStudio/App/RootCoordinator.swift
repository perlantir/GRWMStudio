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
        case error(ErrorVariant)
    }

    enum Overlay: Hashable {
        case preview
        case parentGate(intent: ParentGateIntent)
        case paywall
    }

    enum ParentGateIntent: Hashable {
        case paywall
        case settings
        case deletion
    }

    enum GateReason: Hashable {
        case paywall
        case externalLink(URL)
        case deleteData
    }

    enum PaywallSource: Hashable {
        case proShade
        case lockerLimit
        case longRecording
        case settings
    }

    enum ErrorVariant: Hashable {
        case camDenied
        case micDenied
        case photoDenied
        case license
        case licenseInvalid
        case effectFail
        case recFail
        case saveFail
        case noFace
        case lowStorage
    }

    var route: Route = .onboardingSplash
    var previewAsset: CapturedAsset?
    var previewLookName: String?
    private(set) var overlay: Overlay?

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
        route = .paywall(source: source)
    }

    func presentError(_ variant: ErrorVariant) {
        route = .error(variant)
    }

    func showPreview(asset: CapturedAsset, lookName: String? = nil) {
        previewAsset = asset
        previewLookName = lookName
        overlay = .preview
    }

    func dismissPreview() {
        previewAsset = nil
        previewLookName = nil
        if overlay == .preview {
            overlay = nil
        } else {
            route = .app
        }
    }

    func startParentGate(intent: ParentGateIntent) {
        overlay = .parentGate(intent: intent)
    }

    func paywallShown() {
        overlay = .paywall
    }

    func dismissOverlay() {
        overlay = nil
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
