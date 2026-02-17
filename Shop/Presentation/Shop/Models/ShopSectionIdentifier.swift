import Foundation

enum ShopSectionIdentifier: Hashable {
    case banner(id: String)
    case category(id: String)
    case shopGrid(id: String)
    case fixedBanner(id: String)
    case faq(id: String)
}

enum ShopItemIdentifier: Hashable {
    case banner(Banner)
    case category(Category)
    case shop(ShopItem)
    case fixedBanners(id: String)
    case faq(FAQItem)
}
