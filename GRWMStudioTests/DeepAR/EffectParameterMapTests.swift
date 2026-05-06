@testable import GRWMStudio
import XCTest

final class EffectParameterMapTests: XCTestCase {
    func testEveryDocumentedRefResolves() {
        let refs = [
            "foundationColor",
            "foundationMask",
            "foundationAmount",
            "lutEnabled",
            "lutTexture",
            "lutAmount",
            "eyeshadowColor",
            "eyeshadowMask",
            "eyeshadowEnabled",
            "eyelinerTexture",
            "eyelinerColor",
            "eyelinerEnabled",
            "eyelashesTexture",
            "eyelashesColor",
            "eyelashesEnabled",
            "browColor",
            "browTexture",
            "browEnabled",
            "blushColor",
            "blushMask",
            "blushEnabled",
            "lipsTexture",
            "lipsEnabled"
        ]

        for ref in refs {
            XCTAssertNotNil(EffectParameterMap.resolve(ref), "Missing parameter ref: \(ref)")
        }
    }

    func testVerifiedFreePackNodeNames() {
        XCTAssertEqual(EffectParameterMap.foundationColor.nodeName, "face_makeup")
        XCTAssertEqual(EffectParameterMap.foundationAmount.parameter, "softAmount")
        XCTAssertEqual(EffectParameterMap.eyeshadowColor.nodeName, "eyeshadow")
        XCTAssertEqual(EffectParameterMap.eyeshadowEnabled.parameter, "enabled")
        XCTAssertEqual(EffectParameterMap.eyelinerTexture.nodeName, "eyeliner")
        XCTAssertEqual(EffectParameterMap.eyelinerColor.parameter, "u_color")
        XCTAssertEqual(EffectParameterMap.eyelashesTexture.nodeName, "eyelashes")
        XCTAssertEqual(EffectParameterMap.eyelashesColor.parameter, "u_color")
        XCTAssertEqual(EffectParameterMap.lipsTexture.nodeName, "lips")
    }
}
