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
                titleKey: "looks.section.creator.title",
                subtitleKey: "looks.section.creator.subtitle",
                looks: Looks.all
            )
        ]
    }
}
