import Foundation

struct FAQSection: ShopSection, Sendable {
    let id: String
    let title: String
    let items: [FAQItem]
}
