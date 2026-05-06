@testable import GRWMStudio
import SwiftData
import XCTest

@MainActor
final class FeedViewModelTests: XCTestCase {
    func testLoadReadsFeedCapturesAndBuildsSevenDayBuckets() async throws {
        let container = try makeInMemoryContainer()
        let calendar = Self.utcCalendar
        let today = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 5, day: 6, hour: 12)))
        let todayStart = calendar.startOfDay(for: today)
        let yesterday = try XCTUnwrap(calendar.date(byAdding: .day, value: -1, to: todayStart))
        let oldDay = try XCTUnwrap(calendar.date(byAdding: .day, value: -9, to: todayStart))

        let todayCapture = makeCapture(name: "Today", savedToFeedAt: today)
        let yesterdayCapture = makeCapture(name: "Yesterday", savedToFeedAt: yesterday)
        let oldCapture = makeCapture(name: "Old", savedToFeedAt: oldDay)
        let lockerOnlyCapture = makeCapture(name: "Locker", savedToFeedAt: nil)
        container.mainContext.insert(todayCapture)
        container.mainContext.insert(yesterdayCapture)
        container.mainContext.insert(oldCapture)
        container.mainContext.insert(lockerOnlyCapture)
        try container.mainContext.save()

        let viewModel = FeedViewModel(container.mainContext, calendar: calendar, currentDate: { today })
        await viewModel.load(minimumSkeletonDuration: .milliseconds(0))

        XCTAssertEqual(viewModel.captures.map(\.name), ["Today", "Yesterday", "Old"])
        XCTAssertEqual(viewModel.dayBuckets.count, 8)
        XCTAssertEqual(viewModel.dayBuckets[0].title, "All")
        XCTAssertEqual(viewModel.dayBuckets[0].captureTotal, 3)
        XCTAssertEqual(viewModel.dayBuckets[1].title, "Today")
        XCTAssertEqual(viewModel.dayBuckets[1].captureTotal, 1)
        XCTAssertEqual(viewModel.dayBuckets[2].captureTotal, 1)

        viewModel.selectDay(viewModel.dayBuckets[1])
        XCTAssertEqual(viewModel.visibleCaptures.map(\.name), ["Today"])

        viewModel.selectDay(viewModel.dayBuckets[1])
        XCTAssertEqual(viewModel.visibleCaptures.map(\.name), ["Today", "Yesterday", "Old"])
    }

    func testDeleteRemovesCaptureRecordAndFile() throws {
        let container = try makeInMemoryContainer()
        let fileURL = URL.documentsCapturesURL.appendingPathComponent("\(UUID()).jpg")
        try Data([1, 2, 3]).write(to: fileURL)
        let capture = makeCapture(name: "Delete me", mediaPath: fileURL.lastPathComponent, savedToFeedAt: .now)
        container.mainContext.insert(capture)
        try container.mainContext.save()

        let viewModel = FeedViewModel(container.mainContext)
        viewModel.reload()

        viewModel.delete(capture)

        XCTAssertTrue(viewModel.captures.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileURL.path))
        XCTAssertTrue(try container.mainContext.fetch(FetchDescriptor<SavedCapture>()).isEmpty)
    }

    private func makeCapture(
        name: String,
        mediaPath: String = "\(UUID()).jpg",
        savedToFeedAt: Date?
    ) -> SavedCapture {
        SavedCapture(
            createdAt: savedToFeedAt ?? .now,
            mediaPath: mediaPath,
            kindRaw: SavedCapture.Kind.photo.rawValue,
            name: name,
            savedToFeedAt: savedToFeedAt
        )
    }

    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            SavedCapture.self,
            ProfileRecord.self,
            FavoriteLook.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: configuration)
    }

    private static var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        if let utc = TimeZone(secondsFromGMT: 0) {
            calendar.timeZone = utc
        }
        return calendar
    }
}
