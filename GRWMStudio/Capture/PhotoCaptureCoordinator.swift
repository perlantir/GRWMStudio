import SwiftUI
import UIKit

@MainActor
struct PhotoCaptureCoordinator {
    private let recordingService: RecordingService
    private let simulatorImage: @MainActor () -> UIImage

    init(
        controller: DeepARController,
        simulatorImage: @escaping @MainActor () -> UIImage = PhotoCaptureCoordinator.makeSimulatorImage
    ) {
        recordingService = RecordingService(controller: controller)
        self.simulatorImage = simulatorImage
    }

    func capturePhoto(allowSimulatorPlaceholder: Bool) async throws -> UIImage {
        #if targetEnvironment(simulator)
        if allowSimulatorPlaceholder {
            return simulatorImage()
        }
        #endif

        return try await recordingService.takeScreenshot()
    }

    static func makeSimulatorImage() -> UIImage {
        let size = CGSize(width: 720, height: 1_280)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            UIColor(DH.pinkPaper).setFill()
            context.fill(rect)

            let mirrorRect = CGRect(x: 72, y: 220, width: 576, height: 760)
            let path = UIBezierPath(roundedRect: mirrorRect, cornerRadius: 56)
            UIColor.white.withAlphaComponent(0.7).setFill()
            path.fill()
            UIColor(DH.pink).setStroke()
            path.lineWidth = 10
            path.stroke()

            let text = L10n.string("deepar.placeholder.magic_mirror_plain")
            let font = labelFont(size: 68)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor(DH.pinkDeep)
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: mirrorRect.midY - textSize.height / 2,
                width: textSize.width,
                height: textSize.height
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }

    private static func labelFont(size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Fredoka-Bold", size: size) else {
            preconditionFailure("Fredoka-Bold font is missing from the app bundle.")
        }
        return font
    }
}
