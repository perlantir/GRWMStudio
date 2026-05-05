extension MirrorViewModel {
    func markFaceVisibleForDebugAppShellIfNeeded() {
        #if DEBUG
        guard DebugRuntimeFlags.contains("-GRWMDebugAppShell") else {
            return
        }

        onFaceDetected(true)
        #endif
    }
}
