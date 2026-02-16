import Foundation

protocol ShopRepository {
    func fetchSections() async throws -> [any ShopSection]
}
