import Foundation

struct FixedBannerSection: ShopSection, Sendable {
    let id: String
    let title: String
    let banners: [Banner]
}
