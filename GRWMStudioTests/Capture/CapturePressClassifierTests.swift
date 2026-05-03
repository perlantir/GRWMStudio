@testable import GRWMStudio
import XCTest

final class CapturePressClassifierTests: XCTestCase {
    private let classifier = CapturePressClassifier()

    func testQuickPressClassifiesAsPhoto() {
        XCTAssertEqual(classifier.event(for: 0.29), .photoCapture)
        XCTAssertEqual(classifier.event(for: 0.3), .photoCapture)
    }

    func testLongPressClassifiesAsVideoWithDuration() {
        XCTAssertEqual(classifier.event(for: 5), .videoCapture(duration: 5))
    }

    func testLongPressDurationClampsToFifteenSeconds() {
        XCTAssertEqual(classifier.event(for: 18), .videoCapture(duration: 15))
    }
}
