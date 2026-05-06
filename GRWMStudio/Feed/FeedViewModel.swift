import Foundation
import Observation
import SwiftData

struct FeedDayBucket: Identifiable, Equatable {
    let id: String
    let date: Date?
    let title: String
    let captureTotal: Int
    let isSelected: Bool
}

@MainActor
@Observable
final class FeedViewModel {
    private(set) var isLoading = false
    private(set) var captures: [SavedCapture] = []
    var selectedDay: Date?

    @ObservationIgnored private let modelContext: ModelContext
    @ObservationIgnored private let fileManager: FileManager
    @ObservationIgnored private let calendar: Calendar
    @ObservationIgnored private let currentDate: @MainActor () -> Date

    init(
        _ modelContext: ModelContext,
        fileManager: FileManager = .default,
        calendar: Calendar = .current,
        currentDate: @escaping @MainActor () -> Date = Date.init
    ) {
        self.modelContext = modelContext
        self.fileManager = fileManager
        self.calendar = calendar
        self.currentDate = currentDate
    }

    func load(minimumSkeletonDuration: Duration = .milliseconds(180)) async {
        isLoading = true
        let skeletonDuration = DebugRuntimeFlags.delay(
            minimumSkeletonDuration,
            slowFlag: "-GRWMDebugSlowLoadingStates"
        )

        try? await Task.sleep(for: skeletonDuration)
        reload()
        isLoading = false
    }

    func reload() {
        if DebugRuntimeFlags.contains("-GRWMDebugEmptyFeed") {
            captures = []
            return
        }

        let descriptor = FetchDescriptor<SavedCapture>()
        let fetched = (try? modelContext.fetch(descriptor)) ?? []
        captures = fetched
            .filter(\.isSavedToFeed)
            .sorted { ($0.savedToFeedAt ?? $0.createdAt) > ($1.savedToFeedAt ?? $1.createdAt) }

        if let selectedDay, !dayBuckets.contains(where: { $0.date == selectedDay }) {
            self.selectedDay = nil
        }
    }

    func selectDay(_ day: FeedDayBucket) {
        if selectedDay == day.date {
            selectedDay = nil
        } else {
            selectedDay = day.date
        }
    }

    func delete(_ capture: SavedCapture) {
        let url = captureURL(capture)
        DHAudio.shared.play(.lockerDelete)
        DHHaptics.shared.fire(.heavy)
        modelContext.delete(capture)
        try? modelContext.save()
        try? fileManager.removeItem(at: url)
        reload()
    }

    func captureURL(_ capture: SavedCapture) -> URL {
        URL.documentsCapturesURL.appendingPathComponent(capture.mediaPath)
    }

    var visibleCaptures: [SavedCapture] {
        guard let selectedDay else {
            return captures
        }

        return captures.filter { capture in
            guard let savedToFeedAt = capture.savedToFeedAt else {
                return false
            }
            return calendar.isDate(savedToFeedAt, inSameDayAs: selectedDay)
        }
    }

    var dayBuckets: [FeedDayBucket] {
        let today = calendar.startOfDay(for: currentDate())
        let lastSevenDays = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }

        let allBucket = FeedDayBucket(
            id: "all",
            date: nil,
            title: L10n.string("feed.day.all"),
            captureTotal: captures.count,
            isSelected: selectedDay == nil
        )

        let dayBuckets = lastSevenDays.map { day in
            let count = captures.filter { capture in
                guard let savedToFeedAt = capture.savedToFeedAt else {
                    return false
                }
                return calendar.isDate(savedToFeedAt, inSameDayAs: day)
            }.count

            return FeedDayBucket(
                id: Self.dayID(for: day),
                date: day,
                title: calendar.isDate(day, inSameDayAs: today)
                    ? L10n.string("feed.day.today")
                    : day.formatted(.dateTime.weekday(.abbreviated)),
                captureTotal: count,
                isSelected: selectedDay == day
            )
        }

        return [allBucket] + dayBuckets
    }

    func metadata(for capture: SavedCapture) -> String {
        let kind = L10n.string(capture.kind == .video ? "feed.capture.video" : "feed.capture.photo")
        let savedAt = capture.savedToFeedAt ?? capture.createdAt
        return L10n.format("feed.capture.metadata", kind, savedAt.formatted(date: .abbreviated, time: .omitted))
    }

    private static func dayID(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
