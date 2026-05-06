@testable import GRWMStudio
import XCTest

@MainActor
final class RootCoordinatorTests: XCTestCase {
    func testManageSubscriptionOpensAppStoreAccountAndShowsToastOnFailure() async {
        var openedURLs: [URL] = []
        let coordinator = RootCoordinator(
            openURL: { url, completion in
                openedURLs.append(url)
                completion(false)
            }
        )

        coordinator.parentGatePassed(.manageSubscription)
        await Task.yield()

        XCTAssertEqual(openedURLs, [PurchaseLinks.managePurchases])
        XCTAssertEqual(coordinator.toastMessage, "Couldn't open the App Store. Try later.")
    }

    func testPrivacyLinkDebouncesSecondTapWithinOneSecond() throws {
        var openedURLs: [URL] = []
        var now = Date(timeIntervalSince1970: 100)
        let destination = try XCTUnwrap(URL(string: "https://grwmstudio.app/privacy"))
        let coordinator = RootCoordinator(
            openURL: { url, completion in
                openedURLs.append(url)
                completion(true)
            },
            currentDate: { now }
        )

        coordinator.parentGatePassed(.privacyDeepLink(destination))
        coordinator.parentGatePassed(.privacyDeepLink(destination))

        XCTAssertEqual(openedURLs, [destination])

        now = now.addingTimeInterval(1.1)
        coordinator.parentGatePassed(.privacyDeepLink(destination))

        XCTAssertEqual(openedURLs, [destination, destination])
    }

    func testDeleteAllDataPostsNotification() {
        let notificationCenter = NotificationCenter()
        let coordinator = RootCoordinator(notificationCenter: notificationCenter)
        let expectation = expectation(
            forNotification: .deleteAllRequested,
            object: nil,
            notificationCenter: notificationCenter
        )

        coordinator.parentGatePassed(.deleteAllData)

        wait(for: [expectation], timeout: 0.5)
    }

    func testSaveToPhotosRunsAuthorizedActionAfterParentGatePasses() async {
        let coordinator = RootCoordinator()
        var didRun = false

        coordinator.startParentGate(intent: .saveToPhotos) {
            didRun = true
        }

        coordinator.parentGatePassed(.saveToPhotos)
        await Task.yield()

        XCTAssertTrue(didRun)
        XCTAssertNil(coordinator.presentedParentGate)
    }

    func testPresentErrorUsesFullScreenPresentationState() {
        let coordinator = RootCoordinator()

        coordinator.route = .app
        coordinator.presentError(.camDenied)

        XCTAssertEqual(coordinator.route, .app)
        XCTAssertEqual(coordinator.presentedError, .camDenied)

        coordinator.dismissError()

        XCTAssertNil(coordinator.presentedError)
    }
}
