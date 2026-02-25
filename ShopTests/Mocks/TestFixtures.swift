import Foundation
@testable import Shop

enum TestFixtures {

    static func makeShopItem(
        id: String = "shop-1",
        title: String = "Test Shop",
        tags: [String] = ["tag1", "tag2"]
    ) -> ShopItem {
        ShopItem(
            id: id,
            title: title,
            iconURL: URL(string: "https://example.com/\(id).png")!,
            tags: tags
        )
    }

    static func makeShopGridSection(
        id: String = "SHOP-0",
        title: String = "Shops",
        shops: [ShopItem]? = nil
    ) -> ShopGridSection {
        ShopGridSection(
            id: id,
            title: title,
            shops: shops ?? [makeShopItem()]
        )
    }

    static func makeBannerSection(
        id: String = "BANNER-0",
        banners: [Banner]? = nil
    ) -> BannerSection {
        BannerSection(
            id: id,
            banners: banners ?? [Banner(id: "b1", imageURL: URL(string: "https://example.com/b1.png")!)]
        )
    }

    static func makeCategorySection(
        id: String = "CATEGORY-0",
        title: String = "Categories",
        categories: [Shop.Category]? = nil
    ) -> CategorySection {
        CategorySection(
            id: id,
            title: title,
            categories: categories ?? [
                Shop.Category(id: "c1", title: "Category 1", iconURL: URL(string: "https://example.com/c1.png")!)
            ]
        )
    }

    static func makeFAQSection(
        id: String = "faq-1",
        title: String = "FAQ",
        items: [FAQItem]? = nil
    ) -> FAQSection {
        FAQSection(
            id: id,
            title: title,
            items: items ?? [FAQItem(id: "q1", title: "Question?", answer: "Answer.")]
        )
    }

    static func makeShopResponseDTO() -> ShopResponseDTO {
        ShopResponseDTO(
            home: HomeDTO(
                search: true,
                faq: FAQDTO(id: "faq-1", title: "FAQ", sections: [
                    FAQItemDTO(title: "Q1", description: "A1")
                ]),
                sections: [
                    HomeSectionDTO(title: nil, type: "BANNER", subType: nil, list: ["b1"]),
                    HomeSectionDTO(title: "Categories", type: "CATEGORY", subType: nil, list: ["c1"]),
                    HomeSectionDTO(title: "Shops", type: "SHOP", subType: nil, list: ["s1"]),
                    HomeSectionDTO(title: "Fixed", type: "FIXEDBANNER", subType: nil, list: ["b1"]),
                ]
            ),
            categories: [
                CategoryDTO(id: "c1", title: "Food", iconUrl: "https://example.com/c1.png", status: "active")
            ],
            shops: [
                ShopItemDTO(
                    id: "s1", title: "Coffee Shop", iconUrl: "https://example.com/s1.png",
                    labels: [], tags: ["t1"], categories: ["c1"],
                    about: AboutDTO(title: "About", description: "A coffee shop"),
                    type: ["online"], code: "COFFEE", status: "active"
                )
            ],
            banners: [
                BannerDTO(id: "b1", imageUrl: "https://example.com/b1.png")
            ],
            tags: [
                TagDTO(id: "t1", title: "Coffee", iconUrl: "https://example.com/t1.png", status: "active")
            ],
            labels: [
                LabelDTO(id: "l1", title: "New", status: "active")
            ]
        )
    }
}
