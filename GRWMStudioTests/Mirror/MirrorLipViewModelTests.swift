@testable import GRWMStudio
import XCTest

@MainActor
final class MirrorLipViewModelTests: XCTestCase {
    func testSelectLipShadeAppliesColorTextureAndSelection() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        let shade = try XCTUnwrap(Shade.lipShades.first(where: { $0.id == "lip.petal-pink" }))

        await viewModel.selectShade(in: .lips, shade: shade)

        XCTAssertEqual(viewModel.selectedShadeID(for: .lips), shade.id)
        XCTAssertEqual(viewModel.selections[.lips], SlotSelection(effectID: "lips", shadeID: shade.id, isPro: false))
        XCTAssertTrue(mock.vectorParameters.contains { $0.gameObject == "lips" && $0.parameter == "u_color" })
        XCTAssertTrue(mock.imageParameters.contains { $0.gameObject == "lips" && $0.parameter == "s_texColor" })
        XCTAssertTrue(mock.boolParameters.contains { $0.gameObject == "lips" && $0.parameter == "enabled" && $0.value })
    }

    func testProLipShadeWithoutEntitlementSetsLicenseError() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        let environment = AppEnvironment(
            permissions: MirrorPermissionsStub(camera: .granted),
            proEntitlement: MirrorProEntitlementStub(hasPro: false)
        )
        await viewModel.start(env: environment)

        let shade = try XCTUnwrap(Shade.lipShades.first(where: { $0.id == "lip.disco-brat" }))

        await viewModel.selectShade(in: .lips, shade: shade)

        XCTAssertNil(viewModel.selections[.lips])
        XCTAssertEqual(viewModel.lastError, .license)
        XCTAssertTrue(mock.switches.isEmpty)
    }

    func testProLipShadeWithEntitlementApplies() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        try await controller.bootstrap(licenseKey: "test-license")

        let viewModel = MirrorViewModel(controller: controller)
        let environment = AppEnvironment(
            permissions: MirrorPermissionsStub(camera: .granted),
            proEntitlement: MirrorProEntitlementStub(hasPro: true)
        )
        await viewModel.start(env: environment)

        let shade = try XCTUnwrap(Shade.lipShades.first(where: { $0.id == "lip.disco-brat" }))

        await viewModel.selectShade(in: .lips, shade: shade)

        XCTAssertEqual(viewModel.selectedShadeID(for: .lips), shade.id)
        XCTAssertEqual(viewModel.selections[.lips], SlotSelection(effectID: "lips", shadeID: shade.id, isPro: true))
        XCTAssertTrue(mock.imageParameters.contains { $0.gameObject == "lips" && $0.parameter == "s_texColor" })
    }
}
