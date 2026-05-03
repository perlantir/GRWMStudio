@testable import GRWMStudio
import XCTest

@MainActor
final class FilterCategoryTests: XCTestCase {
    func testCategoriesMatchRailOrder() {
        XCTAssertEqual(
            FilterCategory.allCases,
            [.skin, .base, .eyes, .brows, .cheeks, .lips, .looks]
        )
    }

    func testCategoryLabelsAndSlots() {
        XCTAssertEqual(FilterCategory.skin.label, "Skin")
        XCTAssertEqual(FilterCategory.skin.slot, .skin)
        XCTAssertEqual(FilterCategory.base.label, "Base")
        XCTAssertEqual(FilterCategory.base.slot, .base)
        XCTAssertEqual(FilterCategory.eyes.label, "Eyes")
        XCTAssertEqual(FilterCategory.eyes.slot, .eyes)
        XCTAssertEqual(FilterCategory.brows.label, "Brows")
        XCTAssertEqual(FilterCategory.brows.slot, .brows)
        XCTAssertEqual(FilterCategory.cheeks.label, "Cheeks")
        XCTAssertEqual(FilterCategory.cheeks.slot, .cheeks)
        XCTAssertEqual(FilterCategory.lips.label, "Lips")
        XCTAssertEqual(FilterCategory.lips.slot, .lips)
        XCTAssertEqual(FilterCategory.looks.label, "Looks")
        XCTAssertEqual(FilterCategory.looks.slot, .looks)
    }

    func testMirrorViewModelTracksActiveCategory() {
        let viewModel = MirrorViewModel()

        viewModel.activeCategory = .skin

        XCTAssertEqual(viewModel.activeCategory, .skin)
    }
}
