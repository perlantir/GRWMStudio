extension MirrorViewModel {
    func onFaceDetected(_ detected: Bool) {
        #if DEBUG
        if DebugRuntimeFlags.contains("-GRWMDebugAppShell"), !detected {
            isFaceDetected = true
            noFaceErrorTask?.cancel()
            noFaceErrorTask = nil
            pendingFullScreenError = nil
            return
        }
        #endif

        isFaceDetected = detected

        if detected {
            noFaceErrorTask?.cancel()
            noFaceErrorTask = nil
            return
        }

        guard state == .running, activeCaptureMode == .idle, pendingFullScreenError == nil else {
            return
        }

        guard noFaceErrorTask == nil else {
            return
        }

        noFaceErrorTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            defer { self.noFaceErrorTask = nil }

            try? await Task.sleep(for: self.noFaceDelay)
            guard !Task.isCancelled, !self.isFaceDetected, self.state == .running, self.activeCaptureMode == .idle else {
                return
            }

            self.pendingFullScreenError = .noFace
        }
    }
}
