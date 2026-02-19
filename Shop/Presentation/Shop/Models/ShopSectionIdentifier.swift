import Foundation
import UIKit

enum ShopSectionIdentifier: Hashable {
    case banner(id: String)
    case category(id: String)
    case shopGrid(id: String)
    case fixedBanner(id: String)
    case faq(id: String)

    var sectionId: String {
        switch self {
        case .banner(let id), .category(let id), .shopGrid(let id), .fixedBanner(let id), .faq(let id):
            return id
        }
    }
}

enum ShopItemIdentifier: Hashable {
    case banner(sectionId: String, banner: Banner)
    case category(Category)
    case shop(ShopItem)
    case fixedBanners(id: String)
    case faq(FAQItem)
}

// MARK: - Snapshot Building Protocol

protocol ShopSectionSnapshotProviding: ShopSection {
    
    func appendToSnapshot(_ snapshot: inout NSDiffableDataSourceSnapshot<ShopSectionIdentifier, ShopItemIdentifier>)

    var sectionIdentifier: ShopSectionIdentifier { get }

    var headerTitle: String? { get }

    var headerActionTitle: String? { get }

    var pageIndicatorCount: Int? { get }

    var fixedBannerData: [Banner]? { get }
}
