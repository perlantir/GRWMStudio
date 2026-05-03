@testable import GRWMStudio
import XCTest

final class EffectParameterMapTests: XCTestCase {
    func testEveryDocumentedRefResolves() {
        let refs = [
            "foundationColor",
            "foundationMask",
            "lutEnabled",
            "lutTexture",
            "eyeshadowColor",
            "eyeshadowMask",
            "eyelinerTexture",
            "eyelinerEnabled",
            "eyelashesTexture",
            "eyelashesEnabled",
            "browColor",
            "browTexture",
            "browEnabled",
            "blushColor",
            "blushMask",
            "blushEnabled",
            "lipsColor",
            "lipsTexture",
            "lipsEnabled"
        ]

        for ref in refs {
            XCTAssertNotNil(EffectParameterMap.resolve(ref), "Missing parameter ref: \(ref)")
        }
    }

    func testVerifiedFreePackNodeNames() {
        XCTAssertEqual(EffectParameterMap.foundationColor.nodeName, "face_makeup")
        XCTAssertEqual(EffectParameterMap.lutTexture.nodeName, "PostprocessLUT")
        XCTAssertEqual(EffectParameterMap.eyeshadowColor.nodeName, "eyeshadow")
        XCTAssertEqual(EffectParameterMap.eyelinerTexture.nodeName, "eyeliner")
        XCTAssertEqual(EffectParameterMap.eyelashesTexture.nodeName, "eyelashes")
        XCTAssertEqual(EffectParameterMap.lipsTexture.nodeName, "lips")
    }
}
