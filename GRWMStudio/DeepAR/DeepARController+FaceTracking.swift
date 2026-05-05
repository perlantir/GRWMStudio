import Foundation

extension DeepARController {
    /// Stream of face visibility changes from DeepAR's delegate callbacks.
    public var faceVisibilityStream: AsyncStream<Bool> {
        let id = UUID()
        let pair = AsyncStream.makeStream(of: Bool.self)
        pair.continuation.yield(trackedFace)
        faceVisibilityContinuations[id] = pair.continuation
        pair.continuation.onTermination = { [weak self] _ in
            Task { @MainActor in
                self?.faceVisibilityContinuations[id] = nil
            }
        }
        return pair.stream
    }

    func updateTrackedFace(_ isTracked: Bool) {
        trackedFace = isTracked
        for continuation in faceVisibilityContinuations.values {
            continuation.yield(isTracked)
        }
    }

    func completeBootstrapFromDelegate() {
        bootstrapContinuation?.resume()
        bootstrapContinuation = nil
    }
}
