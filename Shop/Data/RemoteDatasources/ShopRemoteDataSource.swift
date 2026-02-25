import Foundation

protocol ShopRemoteDataSource: Sendable {
    func fetchShopResponse() async throws -> ShopResponseDTO
}

final class DefaultShopRemoteDataSource: ShopRemoteDataSource, Sendable {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func fetchShopResponse() async throws -> ShopResponseDTO {
        try await networkClient.request(
            APIRequest(path: "/ebcom/shop.json")
        )
    }
}
