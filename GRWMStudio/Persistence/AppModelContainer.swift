import SwiftData

@MainActor
enum AppModelContainer {
    static let schema = Schema([
        SavedCapture.self,
        ProfileRecord.self,
        FavoriteLook.self
    ])

    static let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        cloudKitDatabase: .none
    )

    static let container: ModelContainer = {
        do {
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
}
