import Foundation

protocol FetchShopUseCase {
    func execute() async throws -> [any ShopSection]
}

final class DefaultFetchShopUseCase: FetchShopUseCase {

    private let repository: ShopRepository

    init(repository: ShopRepository) {
        self.repository = repository
    }

    func execute() async throws -> [any ShopSection] {
        try await repository.fetchSections()
    }
}
