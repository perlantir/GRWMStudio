@testable import GRWMStudio
import XCTest

@MainActor
final class MirrorControlsViewModelTests: XCTestCase {
    func testFlipCameraTogglesFrontBackState() async {
        let viewModel = MirrorViewModel()

        XCTAssertTrue(viewModel.cameraIsFront)

        await viewModel.flipCamera()

        XCTAssertFalse(viewModel.cameraIsFront)
    }

    func testFlashToggleFlipsOverlayState() {
        let viewModel = MirrorViewModel()

        XCTAssertFalse(viewModel.flashEnabled)

        viewModel.toggleFlash()
        XCTAssertTrue(viewModel.flashEnabled)

        viewModel.toggleFlash()
        XCTAssertFalse(viewModel.flashEnabled)
    }

    func testRecordingStateTracksControllerRecording() {
        let controller = DeepARController()
        let viewModel = MirrorViewModel(controller: controller)

        XCTAssertFalse(viewModel.isRecording)

        controller.isRecordingVideo = true

        XCTAssertTrue(viewModel.isRecording)
    }
}
