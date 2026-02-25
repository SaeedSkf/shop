import Foundation

struct CategorySection: ShopSection, Sendable {
    let id: String
    let title: String
    let categories: [Category]
}
