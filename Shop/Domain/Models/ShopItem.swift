import Foundation

struct ShopItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let iconURL: URL
    let tags: [String]
}
