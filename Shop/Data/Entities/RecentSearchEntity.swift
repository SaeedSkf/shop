import Foundation
import SwiftData

@Model
final class RecentSearchEntity {
    @Attribute(.unique) var term: String
    var createdAt: Date

    init(term: String, createdAt: Date = .now) {
        self.term = term
        self.createdAt = createdAt
    }
}
