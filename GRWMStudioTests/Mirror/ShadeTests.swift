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
}
