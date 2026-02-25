import XCTest
@testable import Shop

// MARK: - SectionFactory Tests

final class SectionFactoryTests: XCTestCase {

    private var sut: DefaultSectionFactory!

    override func setUp() {
        super.setUp()
        sut = DefaultSectionFactory()
    }

    func testMakeSections_mapsAllSectionTypes() {
        let response = TestFixtures.makeShopResponseDTO()

        let sections = sut.makeSections(from: response)

        XCTAssertEqual(sections.count, 5)
        XCTAssertTrue(sections[0] is BannerSection)
        XCTAssertTrue(sections[1] is CategorySection)
        XCTAssertTrue(sections[2] is ShopGridSection)
        XCTAssertTrue(sections[3] is FixedBannerSection)
        XCTAssertTrue(sections[4] is FAQSection)
    }

    func testMakeSections_bannerSectionResolvesBanners() {
        let response = TestFixtures.makeShopResponseDTO()
        let sections = sut.makeSections(from: response)

        let banner = sections[0] as! BannerSection
        XCTAssertEqual(banner.banners.count, 1)
        XCTAssertEqual(banner.banners[0].id, "b1")
    }

    func testMakeSections_categorySectionResolvesCategories() {
        let response = TestFixtures.makeShopResponseDTO()
        let sections = sut.makeSections(from: response)

        let category = sections[1] as! CategorySection
        XCTAssertEqual(category.title, "Categories")
        XCTAssertEqual(category.categories.count, 1)
        XCTAssertEqual(category.categories[0].title, "Food")
    }

    func testMakeSections_shopSectionResolvesShopsWithTags() {
        let response = TestFixtures.makeShopResponseDTO()
        let sections = sut.makeSections(from: response)

        let shopGrid = sections[2] as! ShopGridSection
        XCTAssertEqual(shopGrid.shops.count, 1)
        XCTAssertEqual(shopGrid.shops[0].title, "Coffee Shop")
        XCTAssertEqual(shopGrid.shops[0].tags, ["Coffee"])
    }

    func testMakeSections_faqSectionCreatedFromDTO() {
        let response = TestFixtures.makeShopResponseDTO()
        let sections = sut.makeSections(from: response)

        let faq = sections[4] as! FAQSection
        XCTAssertEqual(faq.title, "FAQ")
        XCTAssertEqual(faq.items.count, 1)
        XCTAssertEqual(faq.items[0].title, "Q1")
        XCTAssertEqual(faq.items[0].answer, "A1")
    }

    func testMakeSections_unknownTypeIsSkipped() {
        let response = ShopResponseDTO(
            home: HomeDTO(
                search: true,
                faq: FAQDTO(id: "faq", title: "FAQ", sections: []),
                sections: [
                    HomeSectionDTO(title: "Unknown", type: "UNKNOWN_TYPE", subType: nil, list: [])
                ]
            ),
            categories: [], shops: [], banners: [], tags: [], labels: []
        )

        let sections = sut.makeSections(from: response)
        XCTAssertEqual(sections.count, 1)
        XCTAssertTrue(sections[0] is FAQSection)
    }

    func testMakeSections_missingBannerIDIsSkipped() {
        let response = ShopResponseDTO(
            home: HomeDTO(
                search: true,
                faq: FAQDTO(id: "faq", title: "FAQ", sections: []),
                sections: [
                    HomeSectionDTO(title: nil, type: "BANNER", subType: nil, list: ["nonexistent"])
                ]
            ),
            categories: [], shops: [], banners: [], tags: [], labels: []
        )

        let sections = sut.makeSections(from: response)
        let banner = sections[0] as! BannerSection
        XCTAssertTrue(banner.banners.isEmpty)
    }
}
