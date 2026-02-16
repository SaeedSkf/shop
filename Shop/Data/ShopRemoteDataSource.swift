import Foundation

protocol ShopRemoteDataSource {
    func fetchShopResponse() async throws -> ShopResponseDTO
}

final class DefaultShopRemoteDataSource: ShopRemoteDataSource {

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
