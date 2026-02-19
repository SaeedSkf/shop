import UIKit

enum ShopLayoutFactory {

    static let pageIndicatorKind = "page-indicator"

    private static let horizontalInset: CGFloat = 20
    private static let categoryItemSize: CGFloat = 64

    static func layoutSection(
        for identifier: ShopSectionIdentifier,
        environment: NSCollectionLayoutEnvironment
    ) -> NSCollectionLayoutSection? {
        switch identifier {
        case .banner:
            return bannerSection(environment: environment)
        case .category:
            return categorySection(environment: environment)
        case .shopGrid:
            return shopGridSection(environment: environment)
        case .fixedBanner:
            return fixedBannerSection(environment: environment)
        case .faq:
            return faqSection(environment: environment)
        }
    }

    // MARK: - Banner (horizontal paging + page indicator footer)

    private static let bannerHeight: CGFloat = 110
    private static let bannerPageIndicatorHeight: CGFloat = 20

    static func bannerSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let containerWidth = environment.container.contentSize.width
        let useAbsoluteWidth = containerWidth > 0
        let itemSize = NSCollectionLayoutSize(
            widthDimension: useAbsoluteWidth ? .absolute(containerWidth) : .fractionalWidth(1.0),
            heightDimension: .absolute(bannerHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: useAbsoluteWidth ? .absolute(containerWidth) : .fractionalWidth(1.0),
            heightDimension: .absolute(bannerHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.contentInsets = .zero

        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(bannerPageIndicatorHeight)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: pageIndicatorKind,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [footer]

        return section
    }

    // MARK: - Category (horizontal continuous scroll)

    static func categorySection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(categoryItemSize),
            heightDimension: .estimated(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(categoryItemSize),
            heightDimension: .estimated(90)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
        section.boundarySupplementaryItems = [makeHeader()]

        return section
    }

    // MARK: - Shop Grid (4 columns)

    private static let shopGridSpacing: CGFloat = 12
    private static let shopGridColumns = 4

    static func shopGridSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let containerWidth = environment.container.contentSize.width
        let contentWidth = containerWidth - (horizontalInset * 2)
        let totalItemSpacing = shopGridSpacing * CGFloat(shopGridColumns - 1)
        let itemWidth = (contentWidth - totalItemSpacing) / CGFloat(shopGridColumns)

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .estimated(120)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(120)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: shopGridColumns)
        group.interItemSpacing = .fixed(shopGridSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = shopGridSpacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
        section.boundarySupplementaryItems = [makeHeader()]

        return section
    }

    // MARK: - Fixed Banner (single cell, self-sizing)

    static func fixedBannerSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
        section.boundarySupplementaryItems = [makeHeader()]

        return section
    }

    // MARK: - FAQ (vertical list)

    static func faqSection(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(60)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: horizontalInset, bottom: 0, trailing: horizontalInset)
        section.boundarySupplementaryItems = [makeHeader()]

        return section
    }

    // MARK: - Shared

    private static func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        return NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
