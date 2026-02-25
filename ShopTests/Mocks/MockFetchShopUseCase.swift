import Foundation
@testable import Shop

final class MockFetchShopUseCase: FetchShopUseCase, @unchecked Sendable {

    var stubbedSections: [any ShopSection] = []
    var stubbedError: Error?
    private(set) var executeCallCount = 0

    func execute() async throws -> [any ShopSection] {
        executeCallCount += 1
        if let error = stubbedError { throw error }
        return stubbedSections
    }
}
