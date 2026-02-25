import Foundation

protocol FetchShopUseCase: Sendable {
    func execute() async throws -> [any ShopSection]
}

final class DefaultFetchShopUseCase: FetchShopUseCase, Sendable {

    private let repository: ShopRepository

    init(repository: ShopRepository) {
        self.repository = repository
    }

    func execute() async throws -> [any ShopSection] {
        try await repository.fetchSections()
    }
}
