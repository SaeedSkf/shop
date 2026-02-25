import Foundation

struct ShopGridSection: ShopSection, Sendable {
    let id: String
    let title: String
    let shops: [ShopItem]
}
