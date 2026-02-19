import Foundation

protocol SectionFactory {
    func makeSections(from response: ShopResponseDTO) -> [any ShopSection]
}

struct DefaultSectionFactory: SectionFactory {

    func makeSections(from response: ShopResponseDTO) -> [any ShopSection] {
        let bannersLookup = Dictionary(uniqueKeysWithValues: response.banners.map { ($0.id, $0) })
        let categoriesLookup = Dictionary(uniqueKeysWithValues: response.categories.map { ($0.id, $0) })
        let shopsLookup = Dictionary(uniqueKeysWithValues: response.shops.map { ($0.id, $0) })
        let tagsLookup = Dictionary(uniqueKeysWithValues: response.tags.map { ($0.id, $0) })

        var sections: [any ShopSection] = response.home.sections.enumerated().compactMap { index, section in
            makeSection(section, index: index, bannersLookup: bannersLookup, categoriesLookup: categoriesLookup, shopsLookup: shopsLookup, tagsLookup: tagsLookup)
        }

        let faqSection = makeFAQSection(from: response.home.faq)
        sections.append(faqSection)

        return sections
    }

    // MARK: - Section Dispatch

    private func makeSection(
        _ section: HomeSectionDTO,
        index: Int,
        bannersLookup: [String: BannerDTO],
        categoriesLookup: [String: CategoryDTO],
        shopsLookup: [String: ShopItemDTO],
        tagsLookup: [String: TagDTO]
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
                shops: resolveShops(ids: section.list, lookup: shopsLookup, tagsLookup: tagsLookup)
            )
        default:
            return nil
        }
    }

    // MARK: - FAQ

    private func makeFAQSection(from dto: FAQDTO) -> FAQSection {
        let items = dto.sections.enumerated().map { index, item in
            FAQItem(
                id: "\(dto.id)-\(index)",
                title: item.title,
                answer: item.description
            )
        }
        return FAQSection(id: dto.id, title: dto.title, items: items)
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

    private func resolveShops(ids: [String], lookup: [String: ShopItemDTO], tagsLookup: [String: TagDTO]) -> [ShopItem] {
        ids.compactMap { id in
            guard let dto = lookup[id], let url = URL(string: dto.iconUrl) else { return nil }
            let resolvedTags = dto.tags.compactMap { tagsLookup[$0]?.title }
            return ShopItem(id: dto.id, title: dto.title, iconURL: url, tags: resolvedTags)
        }
    }
}
