@testable import GRWMStudio
import XCTest

@MainActor
final class CountdownOverlayTests: XCTestCase {
    func testCountdownStepOrderMatchesRecordingCountdown() {
        XCTAssertEqual(CountdownStep.allCases, [.three, .two, .one, .goSignal])
        XCTAssertEqual(CountdownStep.allCases.map(\.label), ["3", "2", "1", "Go!"])
    }

    func testCountdownRunnerCompletesAfterAllSteps() async {
        var steps: [CountdownStep] = []
        var didComplete = false
        let runner = CountdownSequenceRunner(
            onStep: { step in
                steps.append(step)
            },
            onComplete: {
                didComplete = true
            }
        )

        await runner.run()

        XCTAssertEqual(steps, [.three, .two, .one, .goSignal])
        XCTAssertTrue(didComplete)
    }

    func testCountdownRunnerDoesNotCompleteWhenCanceled() async {
        var steps: [CountdownStep] = []
        var didComplete = false
        var isCanceled = false
        let runner = CountdownSequenceRunner(
            onStep: { step in
                steps.append(step)
                isCanceled = true
            },
            onComplete: {
                didComplete = true
            }
        )

        await runner.run(isCancelled: { isCanceled })

        XCTAssertEqual(steps, [.three])
        XCTAssertFalse(didComplete)
    }
}
