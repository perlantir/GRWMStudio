import Foundation
import SwiftData

@MainActor
protocol FavoriteLookStoring {
    func loadFavoriteLookIDs() -> Set<String>
    func toggleFavorite(lookID: String)
}

@MainActor
struct SwiftDataFavoriteLookStore: FavoriteLookStoring {
    let modelContext: ModelContext

    func loadFavoriteLookIDs() -> Set<String> {
        let descriptor = FetchDescriptor<FavoriteLook>()
        let records = (try? modelContext.fetch(descriptor)) ?? []
        return Set(records.map(\.lookID))
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
    }
}
