import Foundation
@testable import Shop

final class MockNetworkClient: NetworkClient, @unchecked Sendable {

    var stubbedData: (any Decodable & Sendable)?
    var stubbedError: Error?
    private(set) var requestedAPIs: [APIRequest] = []

    func request<T: Decodable & Sendable>(_ apiRequest: APIRequest) async throws -> T {
        requestedAPIs.append(apiRequest)
        if let error = stubbedError { throw error }
        guard let data = stubbedData as? T else {
            throw APIError.decodingFailed(
                NSError(domain: "MockNetworkClient", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Stubbed data type mismatch"
                ])
            )
        }
        return data
    }
}
