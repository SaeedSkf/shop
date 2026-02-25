import Foundation
@testable import Shop

final class MockShopRepository: ShopRepository, @unchecked Sendable {

    var stubbedSections: [any ShopSection] = []
    var stubbedError: Error?
    private(set) var fetchCallCount = 0

    func fetchSections() async throws -> [any ShopSection] {
        fetchCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedSections
    }
}
