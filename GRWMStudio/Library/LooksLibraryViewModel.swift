import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class LooksLibraryViewModel {
    private(set) var sections: [LookSection] = []
    private(set) var favorites: Set<String> = []
    private let modelContext: ModelContext

    init(_ modelContext: ModelContext) {
        self.modelContext = modelContext
        buildSections()
        reloadFavorites()
    }

    func reloadFavorites() {
        let descriptor = FetchDescriptor<FavoriteLook>()
        let records = (try? modelContext.fetch(descriptor)) ?? []
        favorites = Set(records.map(\.lookID))
    }

    func toggleFavorite(lookID: String) {
        let descriptor = FetchDescriptor<FavoriteLook>()
        let existing = ((try? modelContext.fetch(descriptor)) ?? []).filter { $0.lookID == lookID }

        if existing.isEmpty {
            modelContext.insert(FavoriteLook(lookID: lookID))
        } else {
            existing.forEach { modelContext.delete($0) }
        }

        try? modelContext.save()
        reloadFavorites()
    }

    func isFavorited(_ lookID: String) -> Bool {
        favorites.contains(lookID)
    }

    var favoritesCount: Int {
        favorites.count
    }

    private func buildSections() {
        if DebugRuntimeFlags.contains("-GRWMDebugEmptyLooks") {
            sections = []
            return
        }

        sections = [
            LookSection(
                titleKey: "looks.section.everyday.title",
                subtitleKey: "looks.section.everyday.subtitle",
                looks: [
                    Looks.byID("look.sunday-best"),
                    Looks.byID("look.school-day")
                ].compactMap { $0 }
            ),
            LookSection(
                titleKey: "looks.section.party.title",
                subtitleKey: "looks.section.party.subtitle",
                looks: [
                    Looks.byID("look.birthday-glam"),
                    Looks.byID("look.sleepover")
                ].compactMap { $0 }
            ),
            LookSection(
                titleKey: "looks.section.pro.title",
                subtitleKey: "looks.section.pro.subtitle",
                looks: [
                    Looks.byID("look.pop-star"),
                    Looks.byID("look.disco-princess"),
                    Looks.byID("look.garden-party"),
                    Looks.byID("look.time-warp")
                ].compactMap { $0 }
            )
        ]
    }
}
