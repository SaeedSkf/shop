import Foundation

protocol ShopRepository: Sendable {
    func fetchSections() async throws -> [any ShopSection]
}
