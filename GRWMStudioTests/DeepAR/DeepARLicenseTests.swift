@testable import GRWMStudio
import XCTest

final class DeepARLicenseTests: XCTestCase {
    func testKeyReadsAndTrimsInfoDictionaryValue() throws {
        let key = try DeepARLicense.key(from: ["DEEPAR_LICENSE_KEY": "  test-key\n"])

        XCTAssertEqual(key, "test-key")
    }

    func testKeyThrowsWhenMissing() {
        XCTAssertThrowsError(try DeepARLicense.key(from: [:])) { error in
            XCTAssertEqual(error as? DeepARLicense.LoadError, .missing)
        }
    }

    func testKeyThrowsWhenEmpty() {
        XCTAssertThrowsError(try DeepARLicense.key(from: ["DEEPAR_LICENSE_KEY": "  \n"])) { error in
            XCTAssertEqual(error as? DeepARLicense.LoadError, .empty)
        }
    }
}
