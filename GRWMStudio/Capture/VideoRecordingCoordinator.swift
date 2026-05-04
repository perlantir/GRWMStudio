import AVFoundation
import Foundation
import SwiftUI
import UIKit

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
            try Self.writePlaceholderVideo(to: url)
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

    private static func writePlaceholderVideo(to url: URL) throws {
        try? FileManager.default.removeItem(at: url)

        let width = 720
        let height = 960
        let writer = try AVAssetWriter(outputURL: url, fileType: .mp4)
        let input = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: width,
                AVVideoHeightKey: height
            ]
        )
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height
            ]
        )

        input.expectsMediaDataInRealTime = false
        guard writer.canAdd(input) else {
            throw CocoaError(.fileWriteUnknown)
        }

        writer.add(input)
        guard writer.startWriting() else {
            throw writer.error ?? CocoaError(.fileWriteUnknown)
        }
        writer.startSession(atSourceTime: .zero)

        for frame in 0..<45 {
            while !input.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.005)
            }

            guard let pixelBuffer = makePixelBuffer(width: width, height: height, frame: frame) else {
                continue
            }

            let time = CMTime(value: CMTimeValue(frame), timescale: 30)
            adaptor.append(pixelBuffer, withPresentationTime: time)
        }

        input.markAsFinished()

        let semaphore = DispatchSemaphore(value: 0)
        writer.finishWriting {
            semaphore.signal()
        }
        semaphore.wait()

        if let error = writer.error {
            throw error
        }
    }

    private static func makePixelBuffer(width: Int, height: Int, frame: Int) -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            nil,
            &pixelBuffer
        )

        guard let pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        guard
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer),
            let context = CGContext(
                data: baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue
                    | CGImageAlphaInfo.premultipliedFirst.rawValue
            )
        else {
            return nil
        }

        context.setFillColor(UIColor(DH.pinkPaper).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        context.setFillColor(UIColor(DH.pinkDeep).cgColor)
        let progress = CGFloat(frame) / 44
        let markerX = 120 + progress * CGFloat(width - 240)
        context.fillEllipse(in: CGRect(x: markerX - 34, y: 520, width: 68, height: 68))

        return pixelBuffer
    }
}
