@testable import GRWMStudio
import SwiftData
import XCTest

@MainActor
final class ProfileRecordTests: XCTestCase {
    func testParentEmailHashNormalizesLowercaseAndWhitespace() {
        let hash = ProfileRecord.parentEmailHash(for: " Parent@Example.COM ")

        XCTAssertEqual(hash, "ee9cd2a3ead6d5cc3b5b0bc3cb19592544d1abf56500a5d9eb87129220ea9236")
    }

    func testParentEmailHashSkipsInvalidOrEmptyEmails() {
        XCTAssertNil(ProfileRecord.parentEmailHash(for: ""))
        XCTAssertNil(ProfileRecord.parentEmailHash(for: "parent-at-example"))
    }

    func testProfileRecordPersistsInLocalSwiftDataContainer() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let record = ProfileRecord(displayName: "Sparkle")
        record.parentEmailHashed = ProfileRecord.parentEmailHash(for: "parent@example.com")

        context.insert(record)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ProfileRecord>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.displayName, "Sparkle")
        XCTAssertEqual(fetched.first?.parentEmailHashed, "ee9cd2a3ead6d5cc3b5b0bc3cb19592544d1abf56500a5d9eb87129220ea9236")
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
