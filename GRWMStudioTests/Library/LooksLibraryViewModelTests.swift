@testable import GRWMStudio
import XCTest

@MainActor
final class LooksLibraryViewModelTests: XCTestCase {
    func testBuildsExpectedCuratedSections() {
        let viewModel = LooksLibraryViewModel(favoriteStore: FakeFavoriteLookStore())

        XCTAssertEqual(viewModel.sections.map(\.titleKey), [
            "looks.section.creator.title"
        ])
        XCTAssertEqual(viewModel.sections.map { $0.looks.count }, [2])
        XCTAssertEqual(viewModel.sections.flatMap(\.looks).map(\.id), Looks.all.map(\.id))
        XCTAssertEqual(LooksLibraryViewModel.curatedSections().count, 1)
    }

    func testToggleFavoriteAddsAndRemovesRecord() {
        let store = FakeFavoriteLookStore()
        let viewModel = LooksLibraryViewModel(favoriteStore: store)

        viewModel.toggleFavorite(lookID: "look.sunday-best")

        XCTAssertTrue(viewModel.isFavorited("look.sunday-best"))
        XCTAssertEqual(viewModel.favoritesCount, 1)
        XCTAssertEqual(store.ids, ["look.sunday-best"])

        viewModel.toggleFavorite(lookID: "look.sunday-best")

        XCTAssertFalse(viewModel.isFavorited("look.sunday-best"))
        XCTAssertEqual(viewModel.favoritesCount, 0)
        XCTAssertTrue(store.ids.isEmpty)
    }

    func testReloadFavoritesReadsStoredRecords() {
        let store = FakeFavoriteLookStore(ids: ["look.school-day"])

        let viewModel = LooksLibraryViewModel(favoriteStore: store)

        XCTAssertEqual(viewModel.favoritesCount, 1)
        XCTAssertTrue(viewModel.isFavorited("look.school-day"))
    }
}

@MainActor
private final class FakeFavoriteLookStore: FavoriteLookStoring {
    var ids: Set<String>

    init(ids: Set<String> = []) {
        self.ids = ids
    }

    func loadFavoriteLookIDs() -> Set<String> {
        ids
    }

    func toggleFavorite(lookID: String) {
        if ids.contains(lookID) {
            ids.remove(lookID)
        } else {
            ids.insert(lookID)
        }
    }
}
