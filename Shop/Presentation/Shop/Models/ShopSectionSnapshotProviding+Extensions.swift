import UIKit

// MARK: - BannerSection

extension BannerSection: ShopSectionSnapshotProviding {
    func appendToSnapshot(_ snapshot: inout NSDiffableDataSourceSnapshot<ShopSectionIdentifier, ShopItemIdentifier>) {
        let sectionId = sectionIdentifier
        snapshot.appendSections([sectionId])
        snapshot.appendItems(banners.map { .banner($0) }, toSection: sectionId)
    }

    var sectionIdentifier: ShopSectionIdentifier { .banner(id: id) }
    var headerTitle: String? { nil }
    var headerActionTitle: String? { nil }
    var pageIndicatorCount: Int? { banners.count }
    var fixedBannerData: [Banner]? { nil }
}

// MARK: - CategorySection

extension CategorySection: ShopSectionSnapshotProviding {
    func appendToSnapshot(_ snapshot: inout NSDiffableDataSourceSnapshot<ShopSectionIdentifier, ShopItemIdentifier>) {
        let sectionId = sectionIdentifier
        snapshot.appendSections([sectionId])
        snapshot.appendItems(categories.map { .category($0) }, toSection: sectionId)
    }

    var sectionIdentifier: ShopSectionIdentifier { .category(id: id) }
    var headerTitle: String? { title }
    var headerActionTitle: String? { NSLocalizedString("see_all", comment: "") }
    var pageIndicatorCount: Int? { nil }
    var fixedBannerData: [Banner]? { nil }
}

// MARK: - ShopGridSection

extension ShopGridSection: ShopSectionSnapshotProviding {
    func appendToSnapshot(_ snapshot: inout NSDiffableDataSourceSnapshot<ShopSectionIdentifier, ShopItemIdentifier>) {
        let sectionId = sectionIdentifier
        snapshot.appendSections([sectionId])
        snapshot.appendItems(shops.map { .shop($0) }, toSection: sectionId)
    }

    var sectionIdentifier: ShopSectionIdentifier { .shopGrid(id: id) }
    var headerTitle: String? { title }
    var headerActionTitle: String? { NSLocalizedString("see_all", comment: "") }
    var pageIndicatorCount: Int? { nil }
    var fixedBannerData: [Banner]? { nil }
}

// MARK: - FixedBannerSection

extension FixedBannerSection: ShopSectionSnapshotProviding {
    func appendToSnapshot(_ snapshot: inout NSDiffableDataSourceSnapshot<ShopSectionIdentifier, ShopItemIdentifier>) {
        let sectionId = sectionIdentifier
        snapshot.appendSections([sectionId])
        snapshot.appendItems([.fixedBanners(id: id)], toSection: sectionId)
    }

    var sectionIdentifier: ShopSectionIdentifier { .fixedBanner(id: id) }
    var headerTitle: String? { title }
    var headerActionTitle: String? { nil }
    var pageIndicatorCount: Int? { nil }
    var fixedBannerData: [Banner]? { banners }
}

// MARK: - FAQSection

extension FAQSection: ShopSectionSnapshotProviding {
    func appendToSnapshot(_ snapshot: inout NSDiffableDataSourceSnapshot<ShopSectionIdentifier, ShopItemIdentifier>) {
        let sectionId = sectionIdentifier
        snapshot.appendSections([sectionId])
        snapshot.appendItems(items.map { .faq($0) }, toSection: sectionId)
    }

    var sectionIdentifier: ShopSectionIdentifier { .faq(id: id) }
    var headerTitle: String? { title }
    var headerActionTitle: String? { nil }
    var pageIndicatorCount: Int? { nil }
    var fixedBannerData: [Banner]? { nil }
}
