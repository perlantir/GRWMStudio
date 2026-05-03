@testable import GRWMStudio
import XCTest

final class ShadeTests: XCTestCase {
    func testSkinShadesAreInclusiveAndFree() {
        XCTAssertEqual(
            Shade.skinShades.map(\.name),
            ["Fair", "Light", "Medium", "Tan", "Deep", "Rich"]
        )
        XCTAssertEqual(Set(Shade.skinShades.map(\.effectID)), Set(["baseBeauty"]))
        XCTAssertTrue(Shade.skinShades.allSatisfy { !$0.isPro })
    }

    func testSkinShadesUseFoundationColorParameter() {
        XCTAssertTrue(
            Shade.skinShades.allSatisfy { shade in
                shade.parameters.contains { $0.ref == "foundationColor" }
            }
        )
    }

    func testBaseShadesAreFreeAndNoneIsDefaultFirst() {
        XCTAssertEqual(
            Shade.baseShades.map(\.id),
            ["base.none", "base.soft", "base.glow", "base.glam"]
        )
        XCTAssertTrue(Shade.baseShades.allSatisfy { !$0.isPro })
        XCTAssertEqual(Shade.baseShades[0].name, "None")
    }

    func testBaseShadesCarryLUTParameters() {
        let glow = Shade.baseShades[2]

        XCTAssertTrue(glow.parameters.contains { $0.ref == "lutEnabled" && $0.value == .enabled(true) })
        XCTAssertTrue(glow.parameters.contains { $0.ref == "lutTexture" && $0.value == .texture("lut_glow") })
    }
}
