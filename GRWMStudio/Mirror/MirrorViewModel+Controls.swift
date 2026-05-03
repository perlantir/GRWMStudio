import OSLog

extension MirrorViewModel {
    var isRecording: Bool {
        controller.isRecordingVideo
    }

    func flipCamera() async {
        cameraIsFront.toggle()
        DHHaptics.light()

        do {
            try await controller.switchCamera(toFront: cameraIsFront)
        } catch {
            Logger.deepAR.error("Camera flip failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func toggleFlash() {
        flashEnabled.toggle()
        DHHaptics.light()
    }
}
