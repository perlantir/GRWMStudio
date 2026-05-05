@testable import GRWMStudio
import SwiftUI
import UIKit
import XCTest

@MainActor
final class MirrorLifecycleViewModelTests: XCTestCase {
    func testQuickForegroundKeepsTextureCacheAndResumesWithoutRebootstrap() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let cache = EffectTextureCache(limit: 2)
        let viewModel = MirrorViewModel(
            controller: controller,
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: false,
            backgroundRetention: .milliseconds(200),
            effectTextureCache: cache
        )

        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))
        let retainedImage = UIImage()
        _ = await cache.image(for: "look-thumb") { retainedImage }

        await viewModel.handleScenePhase(.background)
        try await Task.sleep(for: .milliseconds(40))
        await viewModel.handleScenePhase(.active)

        let imageAfterResume = await cache.image(for: "look-thumb") { UIImage?.none }
        XCTAssertEqual(viewModel.state, .running)
        XCTAssertEqual(controller.state, .ready)
        XCTAssertEqual(mock.createARViewCount, 1)
        XCTAssertEqual(mock.pauseRenderingCount, 1)
        XCTAssertGreaterThanOrEqual(mock.resumeRenderingCount, 1)
        XCTAssertFalse(mock.didShutdown)
        XCTAssertTrue(imageAfterResume === retainedImage)
        XCTAssertEqual(cache.count, 1)
    }

    func testBackgroundTimeoutClearsCacheAndNextForegroundRebootstraps() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let cache = EffectTextureCache(limit: 2)
        let viewModel = MirrorViewModel(
            controller: controller,
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: false,
            backgroundRetention: .milliseconds(30),
            effectTextureCache: cache
        )

        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))
        _ = await cache.image(for: "look-thumb") { UIImage() }

        await viewModel.handleScenePhase(.background)
        try await Task.sleep(for: .milliseconds(80))

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(controller.state, .uninitialized)
        XCTAssertEqual(cache.count, 0)
        XCTAssertTrue(mock.didShutdown)

        await viewModel.handleScenePhase(.active)
        try await waitUntil { viewModel.state == .running && controller.state == .ready }

        XCTAssertEqual(mock.createARViewCount, 2)
    }

    private func waitUntil(
        _ condition: @MainActor @escaping () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async throws {
        for _ in 0..<20 where !condition() {
            try await Task.sleep(for: .milliseconds(10))
        }
        XCTAssertTrue(condition(), file: file, line: line)
    }
}
