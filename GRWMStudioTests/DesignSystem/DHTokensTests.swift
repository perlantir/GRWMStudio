@testable import GRWMStudio
import SwiftUI
import UIKit
import XCTest

final class DHTokensTests: XCTestCase {
    func testColorTokensMatchSpec() {
        assertColor(DH.pink, .rgb(0xFF, 0x3D, 0xA5))
        assertColor(DH.pinkDeep, .rgb(0xD4, 0x12, 0x7B))
        assertColor(DH.pinkLight, .rgb(0xFF, 0xB8, 0xDC))
        assertColor(DH.pinkPaper, .rgb(0xFF, 0xE5, 0xF2))
        assertColor(DH.cream, .rgb(0xFF, 0xF6, 0xFA))
        assertColor(DH.butter, .rgb(0xFF, 0xD6, 0x6B))
        assertColor(DH.butterDeep, .rgb(0xC9, 0x9B, 0x1F))
        assertColor(DH.lavender, .rgb(0xC9, 0xA8, 0xFF))
        assertColor(DH.lavenderDeep, .rgb(0x7A, 0x53, 0xC9))
        assertColor(DH.mint, .rgb(0xA8, 0xE8, 0xC8))
        assertColor(DH.mintDeep, .rgb(0x5D, 0xBD, 0x8E))
        assertColor(DH.ink, .rgb(0x3A, 0x0E, 0x25))
        assertColor(DH.recRed, .rgb(0xFF, 0x2D, 0x5A))
        assertColor(DH.recRedDeep, .rgb(0xB4, 0x15, 0x40))
    }

    func testHexInitializersHandleSixDigitValues() {
        assertUIColor(UIColor(hex: 0x000000), .rgb(0x00, 0x00, 0x00))
        assertUIColor(UIColor(hex: 0xFFFFFF), .rgb(0xFF, 0xFF, 0xFF))
        assertColor(Color(hex: 0xFF3DA5), .rgb(0xFF, 0x3D, 0xA5))
    }

    func testHexInitializersHandleEightDigitValues() {
        assertUIColor(UIColor(hex: 0x11223344), .rgba(0x11, 0x22, 0x33, 0x44))
        assertColor(Color(hex: 0xFFE5F280), .rgba(0xFF, 0xE5, 0xF2, 0x80))
    }

    func testRadiusTokensMatchSpec() {
        XCTAssertEqual(DH.Radius.chip, 17)
        XCTAssertEqual(DH.Radius.card, 24)
        XCTAssertEqual(DH.Radius.bigCard, 32)
        XCTAssertEqual(DH.Radius.viewport, 36)
        XCTAssertEqual(DH.Radius.viewportInner, 28)
        XCTAssertEqual(DH.Radius.swatch, 24)
        XCTAssertEqual(DH.Radius.tile, 22)
    }

    func testSpacingTokensMatchSpec() {
        XCTAssertEqual(DH.Spacing.hPad, 18)
        XCTAssertEqual(DH.Spacing.sectionGap, 18)
        XCTAssertEqual(DH.Spacing.itemGap, 12)
        XCTAssertEqual(DH.Spacing.tightGap, 8)
    }

    private func assertColor(_ color: Color, _ expected: ExpectedColor, file: StaticString = #filePath, line: UInt = #line) {
        assertComponents(UIColor(color), expected, file: file, line: line)
    }

    private func assertUIColor(_ color: UIColor, _ expected: ExpectedColor, file: StaticString = #filePath, line: UInt = #line) {
        assertComponents(color, expected, file: file, line: line)
    }

    private func assertComponents(
        _ color: UIColor,
        _ expected: ExpectedColor,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let resolved = color.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        XCTAssertTrue(resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha), file: file, line: line)
        XCTAssertEqual(red, CGFloat(expected.red) / 255, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(green, CGFloat(expected.green) / 255, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(blue, CGFloat(expected.blue) / 255, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(alpha, expected.alpha, accuracy: 0.01, file: file, line: line)
    }

    private struct ExpectedColor {
        let red: UInt8
        let green: UInt8
        let blue: UInt8
        let alpha: CGFloat

        static func rgb(_ red: UInt8, _ green: UInt8, _ blue: UInt8) -> Self {
            .init(red: red, green: green, blue: blue, alpha: 1)
        }

        static func rgba(_ red: UInt8, _ green: UInt8, _ blue: UInt8, _ alpha: UInt8) -> Self {
            .init(red: red, green: green, blue: blue, alpha: CGFloat(alpha) / 255)
        }
    }
}
