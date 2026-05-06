@testable import GRWMStudio
import SwiftUI
import UIKit
import XCTest

@MainActor
final class MirrorLifecycleViewModelTests: XCTestCase {
    func testRefreshCameraAuthorizationRestartsAfterGrantAndClearsDeniedError() async throws {
        let permissions = VariableMirrorPermissionsStub(camera: .notDetermined)
        let viewModel = MirrorViewModel(licenseLoader: { "test-license" }, usesSimulatorPlaceholder: true)
        let environment = AppEnvironment(permissions: permissions)

        await viewModel.start(env: environment)
        XCTAssertEqual(viewModel.state, .needsPermission)

        permissions.camera = .denied
        await viewModel.refreshCameraAuthorization()
        XCTAssertEqual(viewModel.state, .needsPermission)
        XCTAssertEqual(viewModel.pendingFullScreenError, .camDenied)

        permissions.camera = .granted
        await viewModel.refreshCameraAuthorization()

        XCTAssertEqual(viewModel.state, .running)
        XCTAssertNil(viewModel.pendingFullScreenError)
    }

    func testRefreshCameraAuthorizationWithoutEnvironmentIsNoOp() async {
        let viewModel = MirrorViewModel(licenseLoader: { "test-license" }, usesSimulatorPlaceholder: true)

        await viewModel.refreshCameraAuthorization()

        XCTAssertEqual(viewModel.state, .idle)
    }

    func testInactiveScenePhaseDoesNotChangeRunningMirror() async {
        let viewModel = MirrorViewModel(licenseLoader: { "test-license" }, usesSimulatorPlaceholder: true)
        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))

        await viewModel.handleScenePhase(.inactive)

        XCTAssertEqual(viewModel.state, .running)
    }

    func testPauseFromRunningStopsCameraAndClearsPreviewState() async throws {
        let mock = MirrorMockDeepARClient(autoInitialize: true, autoSwitchEffect: true)
        let controller = DeepARController(clientFactory: { mock }, bootstrapTimeout: .seconds(1))
        let viewModel = MirrorViewModel(
            controller: controller,
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: false
        )

        await viewModel.start(env: AppEnvironment(permissions: MirrorPermissionsStub(camera: .granted)))
        viewModel.pendingPreviewAsset = .photo(UIImage())
        viewModel.previewRouteID = UUID()

        viewModel.pause()
        try await Task.sleep(for: .milliseconds(20))

        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertNil(viewModel.pendingPreviewAsset)
        XCTAssertNil(viewModel.previewRouteID)
        XCTAssertEqual(controller.state, .ready)
    }

    func testSampleFaceLoaderMarksFaceVisibleWhenAvailable() async {
        let viewModel = MirrorViewModel(
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: true,
            sampleFaceLoader: { true }
        )

        await viewModel.useSampleFaceIfAvailable()

        XCTAssertTrue(viewModel.isFaceDetected)
    }

    func testSampleFaceLoaderFalseLeavesFaceHidden() async {
        let viewModel = MirrorViewModel(
            licenseLoader: { "test-license" },
            usesSimulatorPlaceholder: true,
            sampleFaceLoader: { false }
        )

        await viewModel.useSampleFaceIfAvailable()

        XCTAssertFalse(viewModel.isFaceDetected)
    }

    func testRetryLastCaptureFailureNoOpsWithoutFailureKind() async {
        let viewModel = MirrorViewModel(licenseLoader: { "test-license" }, usesSimulatorPlaceholder: true)

        await viewModel.retryLastCaptureFailure()

        XCTAssertNil(viewModel.pendingFullScreenError)
    }

    func testEscalateEffectFailureTransitionsToFailedState() {
        let viewModel = MirrorViewModel(licenseLoader: { "test-license" }, usesSimulatorPlaceholder: true)

        viewModel.escalateEffectFailure()

        XCTAssertEqual(viewModel.state, .failed(.effectFail))
    }

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
