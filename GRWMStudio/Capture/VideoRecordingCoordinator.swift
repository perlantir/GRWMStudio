import Foundation

@MainActor
protocol VideoRecordingCoordinating: AnyObject {
    var currentURL: URL? { get }

    func start() async throws -> URL
    func finish() async throws -> URL
    func reset()
}

@MainActor
final class VideoRecordingCoordinator: VideoRecordingCoordinating {
    private let recordingService: RecordingService
    private let allowSimulatorPlaceholder: Bool
    private(set) var currentURL: URL?

    init(controller: DeepARController, allowSimulatorPlaceholder: Bool) {
        recordingService = RecordingService(controller: controller)
        self.allowSimulatorPlaceholder = allowSimulatorPlaceholder
    }

    func start() async throws -> URL {
        if allowSimulatorPlaceholder {
            let url = Self.makeTemporaryMP4URL()
            try Data("GRWM DEBUG VIDEO PLACEHOLDER".utf8).write(to: url, options: .atomic)
            currentURL = url
            return url
        }

        let url = try await recordingService.startVideoRecording()
        currentURL = url
        return url
    }

    func finish() async throws -> URL {
        if allowSimulatorPlaceholder, let currentURL {
            self.currentURL = nil
            return currentURL
        }

        let url = try await recordingService.finishVideoRecording()
        currentURL = nil
        return url
    }

    func reset() {
        currentURL = nil
    }

    static func makeTemporaryMP4URL() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("rec_\(UUID().uuidString).mp4")
    }
}
