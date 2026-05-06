@testable import GRWMStudio
import SwiftUI

@MainActor
final class PrimitiveSnapshotTests: SnapshotTestCase {
    func testDHButtonsRenderCoreStates() throws {
        try assertScreen(
            VStack(spacing: 18) {
                DHButton(title: "Primary", kind: .primary, size: .lg) {}
                DHButton(title: "White", kind: .white, size: .md) {}
                DHButton(title: "Ghost", kind: .ghost, size: .sm) {}
            }
            .padding(32)
            .background(DHWallpaperGradient()),
            named: "dh-buttons-core-states"
        )
    }

    func testErrorVariantRenders() throws {
        try assertScreen(
            DHErrorView(variant: .camDenied, onCTA: {}, onAlt: {}, onClose: {})
                .background(DHWallpaperGradient()),
            named: "error-cam-denied"
        )
    }
}
