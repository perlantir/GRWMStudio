@testable import GRWMStudio
import SwiftData
import XCTest

@MainActor
final class LockerViewModelTests: XCTestCase {
    func testGlowLevelLabelFormatsNumericLevelSafely() throws {
        let container = try makeInMemoryContainer()
        let viewModel = LockerViewModel(ModelContext(container))

        XCTAssertEqual(viewModel.glowLevelLabel, "Glow Level 1")
    }

    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            SavedCapture.self,
            ProfileRecord.self,
            FavoriteLook.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
