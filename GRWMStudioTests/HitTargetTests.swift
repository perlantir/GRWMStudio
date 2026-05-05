import XCTest

final class HitTargetTests: XCTestCase {
    func testCoreHitTargetMarkersArePresentInSource() throws {
        let captureKindPicker = try sourceFile("GRWMStudio/App/AppShell.swift")
        let toggle = try sourceFile("GRWMStudio/Settings/Toggle/DHToggle.swift")
        let heartPill = try sourceFile("GRWMStudio/Feed/FeedHeartPill.swift")
        let preview = try sourceFile("GRWMStudio/Capture/PreviewPlaceholderView.swift")

        XCTAssertTrue(captureKindPicker.contains(".frame(minWidth: 44, minHeight: 44)"))
        XCTAssertTrue(toggle.contains(".frame(minWidth: 44, minHeight: 44)"))
        XCTAssertTrue(heartPill.contains(".frame(width: 44, height: 44)"))
        XCTAssertTrue(preview.contains(".frame(width: 44, height: 44)"))
    }

    func testContrastAuditScriptExistsAndChecksForZeroFailures() throws {
        let script = try sourceFile("Scripts/audit-contrast.swift")

        XCTAssertTrue(script.contains("Contrast audit complete: 0 failures."))
        XCTAssertTrue(script.contains("Primary button copy"))
        XCTAssertTrue(script.contains("Large label on recording red"))
    }

    private func sourceFile(_ relativePath: String) throws -> String {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let url = root.appendingPathComponent(relativePath)
        return try String(contentsOf: url, encoding: .utf8)
    }
}
