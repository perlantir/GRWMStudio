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

    func testEyeshadowShadesAreFreeAndCarryColorAndMaskParameters() {
        XCTAssertEqual(
            Shade.eyeshadowShades.map(\.id),
            [
                "eyeshadow.pink",
                "eyeshadow.purple",
                "eyeshadow.gold",
                "eyeshadow.teal",
                "eyeshadow.brown",
                "eyeshadow.blue"
            ]
        )
        XCTAssertTrue(Shade.eyeshadowShades.allSatisfy { !$0.isPro })

        let pink = Shade.eyeshadowShades[0]
        XCTAssertTrue(pink.parameters.contains { $0.ref == "eyeshadowColor" })
        XCTAssertTrue(pink.parameters.contains { $0.ref == "eyeshadowMask" && $0.value == .texture("eyeshadow_basic") })
    }

    func testEyelinerShadesCarryFreeAndProStyles() {
        XCTAssertEqual(
            Shade.eyelinerShades.map(\.id),
            ["eyeliner.none", "eyeliner.classic", "eyeliner.winged", "eyeliner.double-flick"]
        )
        XCTAssertEqual(Shade.eyelinerShades.map(\.isPro), [false, false, true, true])
        XCTAssertTrue(Shade.eyelinerShades[0].parameters.contains { $0.ref == "eyelinerEnabled" && $0.value == .enabled(false) })
        XCTAssertTrue(Shade.eyelinerShades[1].parameters.contains { $0.ref == "eyelinerEnabled" && $0.value == .enabled(true) })
        XCTAssertTrue(
            Shade.eyelinerShades[1].parameters.contains {
                $0.ref == "eyelinerTexture" && $0.value == .texture("eyeliner_classic")
            }
        )
    }

    func testEyelashShadesCarryFreeAndProStyles() {
        XCTAssertEqual(
            Shade.eyelashShades.map(\.id),
            ["eyelashes.none", "eyelashes.natural", "eyelashes.doll", "eyelashes.drama"]
        )
        XCTAssertEqual(Shade.eyelashShades.map(\.isPro), [false, false, true, true])
        XCTAssertTrue(Shade.eyelashShades[0].parameters.contains { $0.ref == "eyelashesEnabled" && $0.value == .enabled(false) })
        XCTAssertTrue(Shade.eyelashShades[1].parameters.contains { $0.ref == "eyelashesEnabled" && $0.value == .enabled(true) })
        XCTAssertTrue(
            Shade.eyelashShades[1].parameters.contains {
                $0.ref == "eyelashesTexture" && $0.value == .texture("eyelashes_natural")
            }
        )
    }
}
