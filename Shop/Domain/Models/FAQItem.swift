import Foundation

struct FAQItem: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let answer: String
}
