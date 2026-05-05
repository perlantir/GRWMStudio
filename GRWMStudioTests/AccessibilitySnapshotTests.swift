import XCTest

final class AccessibilitySnapshotTests: XCTestCase {
    func testCaptureFABAccessibilityCopyIsPresentInSource() throws {
        let source = try sourceFile("GRWMStudio/Capture/CaptureFAB.swift")

        XCTAssertTrue(source.contains(".accessibilityLabel(L10n.string(\"capture.fab.accessibility_label\"))"))
        XCTAssertTrue(source.contains("capture.fab.photo_hint"))
        XCTAssertTrue(source.contains("capture.fab.video_hint"))
        XCTAssertTrue(source.contains(".accessibilityValue(accessibilityValue)"))
    }

    func testShadeTrayAndTabBarAccessibilitySourceMarkersArePresent() throws {
        let shadeTray = try sourceFile("GRWMStudio/Mirror/ShadeTrayView.swift")
        let tabBar = try sourceFile("GRWMStudio/DesignSystem/DHTabBar.swift")

        XCTAssertTrue(shadeTray.contains(".accessibilityHint(L10n.string(\"mirror.shade.accessibility_hint\"))"))
        XCTAssertTrue(shadeTray.contains("common.index_of_total"))
        XCTAssertTrue(shadeTray.contains(".accessibilityIdentifier(\"\\(shade.localizedName) \\(category.label) shade\")"))
        XCTAssertTrue(tabBar.contains(".accessibilityElement(children: .ignore)"))
        XCTAssertTrue(tabBar.contains("L10n.string(\"common.selected\")"))
        XCTAssertTrue(tabBar.contains("L10n.string(\"common.not_selected\")"))
        XCTAssertTrue(tabBar.contains(".accessibilityAddTraits(.isTabBar)"))
    }

    func testDynamicTypeClampIsAppliedAtAppRoot() throws {
        let app = try sourceFile("GRWMStudio/App/GRWMStudioApp.swift")
        let fonts = try sourceFile("GRWMStudio/DesignSystem/DH+Fonts.swift")

        XCTAssertTrue(app.contains(".dynamicTypeSize(...DynamicTypeSize.accessibility2)"))
        XCTAssertTrue(fonts.contains(".custom(style.fontName, size: style.size, relativeTo: style.relativeTextStyle)"))
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let url = root.appendingPathComponent(relativePath)
        return try String(contentsOf: url, encoding: .utf8)
    }
}
