import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class LooksLibraryViewModel {
    private(set) var sections: [LookSection] = []
    private(set) var favorites: Set<String> = []
    @ObservationIgnored
    private let favoriteStore: any FavoriteLookStoring

    init(_ modelContext: ModelContext) {
        self.favoriteStore = SwiftDataFavoriteLookStore(modelContext: modelContext)
        buildSections()
        reloadFavorites()
    }

    init(favoriteStore: any FavoriteLookStoring) {
        self.favoriteStore = favoriteStore
        buildSections()
        reloadFavorites()
    }

    func reloadFavorites() {
        favorites = favoriteStore.loadFavoriteLookIDs()
    }

    func toggleFavorite(lookID: String) {
        favoriteStore.toggleFavorite(lookID: lookID)
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

        sections = Self.curatedSections()
    }

    static func curatedSections() -> [LookSection] {
        [
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
