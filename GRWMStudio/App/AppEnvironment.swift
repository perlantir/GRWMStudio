import SwiftUI

final class AppEnvironment {
    let deepAR: any DeepARService
    let catalog: any EffectCatalogService
    let captures: CaptureService
    let permissions: any PermissionsService
    let storeKit: any StoreKitService
    let proEntitlement: any ProEntitlementService
    let analytics: any AnalyticsService
    let feed: any FeedService
    let parentalGate: any ParentalGateService

    init(
        deepAR: any DeepARService = StubDeepARService(),
        catalog: any EffectCatalogService = StubEffectCatalogService(),
        captures: CaptureService = CaptureService(),
        permissions: any PermissionsService = DefaultPermissionsService(),
        storeKit: any StoreKitService = StubStoreKitService(),
        proEntitlement: any ProEntitlementService = StubProEntitlementService(),
        analytics: any AnalyticsService = NoOpAnalyticsService(),
        feed: any FeedService = StubFeedService(),
        parentalGate: any ParentalGateService = StubParentalGateService()
    ) {
        self.deepAR = deepAR
        self.catalog = catalog
        self.captures = captures
        self.permissions = permissions
        self.storeKit = storeKit
        self.proEntitlement = proEntitlement
        self.analytics = analytics
        self.feed = feed
        self.parentalGate = parentalGate
    }
}

protocol DeepARService: Sendable {}
struct StubDeepARService: DeepARService {}

protocol EffectCatalogService: Sendable {}
struct StubEffectCatalogService: EffectCatalogService {}

protocol StoreKitService: Sendable {}
struct StubStoreKitService: StoreKitService {}

protocol ProEntitlementService: Sendable {}
struct StubProEntitlementService: ProEntitlementService {}

protocol AnalyticsService: Sendable {
    func track(_ event: String, properties: [String: Any]?)
}

struct NoOpAnalyticsService: AnalyticsService {
    func track(_ event: String, properties: [String: Any]?) {}
}

protocol FeedService: Sendable {}
struct StubFeedService: FeedService {}

protocol ParentalGateService: Sendable {}
struct StubParentalGateService: ParentalGateService {}

extension EnvironmentValues {
    @Entry var appEnvironment: AppEnvironment = AppEnvironment()
}
