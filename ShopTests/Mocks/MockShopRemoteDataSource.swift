import Foundation
@testable import Shop

final class MockShopRemoteDataSource: ShopRemoteDataSource, @unchecked Sendable {

    var stubbedResponse: ShopResponseDTO?
    var stubbedError: Error?
    private(set) var fetchCallCount = 0

    func fetchShopResponse() async throws -> ShopResponseDTO {
        fetchCallCount += 1
        if let error = stubbedError { throw error }
        guard let response = stubbedResponse else {
            throw APIError.invalidResponse
        }
        return response
    }
}
