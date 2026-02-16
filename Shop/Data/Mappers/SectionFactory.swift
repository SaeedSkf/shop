import Foundation

protocol SectionFactory {
    func makeSections(from response: ShopResponseDTO) -> [any ShopSection]
}

struct DefaultSectionFactory: SectionFactory {

    func makeSections(from response: ShopResponseDTO) -> [any ShopSection] {
        let bannersLookup = Dictionary(uniqueKeysWithValues: response.banners.map { ($0.id, $0) })
        let categoriesLookup = Dictionary(uniqueKeysWithValues: response.categories.map { ($0.id, $0) })
        let shopsLookup = Dictionary(uniqueKeysWithValues: response.shops.map { ($0.id, $0) })

        return response.home.sections.enumerated().compactMap { index, section in
            makeSection(section, index: index, bannersLookup: bannersLookup, categoriesLookup: categoriesLookup, shopsLookup: shopsLookup)
        }
    }

    // MARK: - Section Dispatch

    private func makeSection(
        _ section: HomeSectionDTO,
        index: Int,
        bannersLookup: [String: BannerDTO],
        categoriesLookup: [String: CategoryDTO],
        shopsLookup: [String: ShopItemDTO]
    ) -> (any ShopSection)? {
        switch section.type {
        case "BANNER":
            return BannerSection(
                id: "\(section.type)-\(index)",
                banners: resolveBanners(ids: section.list, lookup: bannersLookup)
            )
        case "FIXEDBANNER":
            return FixedBannerSection(
                id: "\(section.type)-\(index)",
                title: section.title ?? "",
                banners: resolveBanners(ids: section.list, lookup: bannersLookup)
            )
        case "CATEGORY":
            return CategorySection(
                id: "\(section.type)-\(index)",
                title: section.title ?? "",
                categories: resolveCategories(ids: section.list, lookup: categoriesLookup)
            )
        case "SHOP":
            return ShopGridSection(
                id: "\(section.type)-\(index)",
                title: section.title ?? "",
                shops: resolveShops(ids: section.list, lookup: shopsLookup)
            )
        default:
            return nil
        }
    }

    // MARK: - Resolvers

    private func resolveBanners(ids: [String], lookup: [String: BannerDTO]) -> [Banner] {
        ids.compactMap { id in
            guard let dto = lookup[id], let url = URL(string: dto.imageUrl) else { return nil }
            return Banner(id: dto.id, imageURL: url)
        }
    }

    private func resolveCategories(ids: [String], lookup: [String: CategoryDTO]) -> [Category] {
        ids.compactMap { id in
            guard let dto = lookup[id], let url = URL(string: dto.iconUrl) else { return nil }
            return Category(id: dto.id, title: dto.title, iconURL: url)
        }
    }

    private func resolveShops(ids: [String], lookup: [String: ShopItemDTO]) -> [ShopItem] {
        ids.compactMap { id in
            guard let dto = lookup[id], let url = URL(string: dto.iconUrl) else { return nil }
            return ShopItem(id: dto.id, title: dto.title, iconURL: url)
        }
    }
}
