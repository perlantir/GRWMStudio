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
                    && shade.parameters.contains { $0.ref == "foundationAmount" }
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

    func testBaseShadesCarryFaceOnlyFoundationParameters() {
        let glow = Shade.baseShades[2]

        XCTAssertTrue(glow.parameters.contains { $0.ref == "foundationColor" })
        XCTAssertTrue(glow.parameters.contains { $0.ref == "foundationAmount" && $0.value == .blendshape(0.56) })
        XCTAssertFalse(glow.parameters.contains { $0.ref == "lutTexture" })
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
            [
                "eyeliner.none",
                "eyeliner.pink",
                "eyeliner.purple",
                "eyeliner.gold",
                "eyeliner.teal",
                "eyeliner.brown",
                "eyeliner.blue",
                "eyeliner.classic",
                "eyeliner.winged",
                "eyeliner.double-flick"
            ]
        )
        XCTAssertEqual(Shade.eyelinerShades.map(\.isPro), [false, false, false, false, false, false, false, false, true, true])
        XCTAssertTrue(Shade.eyelinerShades[0].parameters.contains { $0.ref == "eyelinerEnabled" && $0.value == .enabled(false) })
        XCTAssertTrue(Shade.eyelinerShades[1].parameters.contains { $0.ref == "eyelinerEnabled" && $0.value == .enabled(true) })
        XCTAssertTrue(Shade.eyelinerShades[1].parameters.contains { $0.ref == "eyelinerColor" })
        XCTAssertTrue(
            Shade.eyelinerShades[1].parameters.contains {
                $0.ref == "eyelinerTexture" && $0.value == .texture("eyeliner_classic")
            }
        )
    }

    func testEyelashShadesCarryFreeAndProStyles() {
        XCTAssertEqual(
            Shade.eyelashShades.map(\.id),
            [
                "eyelashes.none",
                "eyelashes.pink",
                "eyelashes.purple",
                "eyelashes.gold",
                "eyelashes.teal",
                "eyelashes.brown",
                "eyelashes.blue",
                "eyelashes.natural",
                "eyelashes.doll",
                "eyelashes.drama"
            ]
        )
        XCTAssertEqual(Shade.eyelashShades.map(\.isPro), [false, false, false, false, false, false, false, false, true, true])
        XCTAssertTrue(Shade.eyelashShades[0].parameters.contains { $0.ref == "eyelashesEnabled" && $0.value == .enabled(false) })
        XCTAssertTrue(Shade.eyelashShades[1].parameters.contains { $0.ref == "eyelashesEnabled" && $0.value == .enabled(true) })
        XCTAssertTrue(Shade.eyelashShades[1].parameters.contains { $0.ref == "eyelashesColor" })
        XCTAssertTrue(
            Shade.eyelashShades[1].parameters.contains {
                $0.ref == "eyelashesTexture" && $0.value == .texture("eyelashes_natural")
            }
        )
    }

    func testEyeTexturesStayOnTheirDeepARSourceMeshes() throws {
        try assertTexture("eyeliner_classic.png", matchesSource: "smooth.png")
        try assertTexture("eyeliner_winged.png", matchesSource: "luxe.png")
        try assertTexture("eyeliner_double_flick.png", matchesSource: "luxe.png")
        try assertTexture("eyelashes_natural.png", matchesSource: "sexy.png")
        try assertTexture("eyelashes_doll.png", matchesSource: "gorgeous.png")
        try assertTexture("eyelashes_drama.png", matchesSource: "gorgeous.png")

        try assertTexture("eyeliner_winged.png", doesNotMatchSource: "gorgeous.png")
        try assertTexture("eyelashes_drama.png", doesNotMatchSource: "luxe.png")
    }

    func testBrowShadesAreFreeAndCarryNaturalShapeParameters() {
        XCTAssertEqual(
            Shade.browShades.map(\.id),
            ["brow.blonde", "brow.brown", "brow.darkBrown", "brow.black", "brow.softPink"]
        )
        XCTAssertTrue(Shade.browShades.allSatisfy { !$0.isPro })

        let brown = Shade.browShades[1]
        XCTAssertEqual(brown.effectID, "brows")
        XCTAssertTrue(brown.parameters.contains { $0.ref == "browColor" })
        XCTAssertTrue(brown.parameters.contains { $0.ref == "browTexture" && $0.value == .texture("brows_natural") })
        XCTAssertTrue(brown.parameters.contains { $0.ref == "browEnabled" && $0.value == .enabled(true) })
    }

    func testCheekShadesAreFreeAndCarryBlushParameters() {
        XCTAssertEqual(
            Shade.cheekShades.map(\.id),
            ["cheek.pink", "cheek.peach", "cheek.coral", "cheek.mauve", "cheek.berry"]
        )
        XCTAssertTrue(Shade.cheekShades.allSatisfy { !$0.isPro })

        let coral = Shade.cheekShades[2]
        XCTAssertEqual(coral.effectID, "blush")
        XCTAssertTrue(coral.parameters.contains { $0.ref == "blushColor" })
        XCTAssertTrue(coral.parameters.contains { $0.ref == "blushMask" && $0.value == .texture("blush_mask") })
        XCTAssertTrue(coral.parameters.contains { $0.ref == "blushEnabled" && $0.value == .enabled(true) })
    }

    func testLipShadesCarryFreeAndProStyles() {
        XCTAssertEqual(
            Shade.lipShades.map(\.id),
            [
                "lip.classic-red",
                "lip.petal-pink",
                "lip.nude",
                "lip.berry",
                "lip.coral",
                "lip.pink",
                "lip.purple",
                "lip.gold",
                "lip.teal",
                "lip.brown",
                "lip.blue",
                "lip.plum",
                "lip.neon-pink",
                "lip.disco-brat"
            ]
        )
        XCTAssertEqual(
            Shade.lipShades.map(\.isPro),
            [false, false, false, false, false, false, false, false, false, false, false, true, true, true]
        )

        let petal = Shade.lipShades[1]
        XCTAssertEqual(petal.effectID, "lips")
        XCTAssertFalse(petal.parameters.contains { $0.ref == "lipsColor" })
        XCTAssertTrue(petal.parameters.contains { $0.ref == "lipsTexture" && $0.value == .texture("lips_gloss") })
        XCTAssertTrue(petal.parameters.contains { $0.ref == "lipsEnabled" && $0.value == .enabled(true) })

        let purple = Shade.lipShades[6]
        XCTAssertTrue(
            purple.parameters.contains {
                $0.ref == "lipsTexture"
                    && $0.value == .tintedTexture("lips_matte", RGBA(0.64, 0.42, 1.00, 0.88))
            }
        )
    }

    private func assertTexture(_ textureName: String, matchesSource sourceName: String) throws {
        XCTAssertEqual(
            try textureData(textureName),
            try sourceTextureData(sourceName),
            "\(textureName) must preserve the DeepAR source UV layout from \(sourceName)."
        )
    }

    private func assertTexture(_ textureName: String, doesNotMatchSource sourceName: String) throws {
        XCTAssertNotEqual(
            try textureData(textureName),
            try sourceTextureData(sourceName),
            "\(textureName) is mapped to the wrong DeepAR face region source texture."
        )
    }

    private func textureData(_ filename: String) throws -> Data {
        try Data(contentsOf: repoRoot.appendingPathComponent("GRWMStudio/Resources/Effects/textures/\(filename)"))
    }

    private func sourceTextureData(_ filename: String) throws -> Data {
        try Data(contentsOf: repoRoot.appendingPathComponent(sourceTexturePath(filename)))
    }

    private var repoRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func sourceTexturePath(_ filename: String) -> String {
        "GRWMStudio/Resources/Effects/_source/Free.v1.3/baseBeauty.deeparproj/resources/\(filename)"
    }
}
