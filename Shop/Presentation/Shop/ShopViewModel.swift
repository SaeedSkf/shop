import Combine
import Foundation

final class ShopViewModel {

    @Published private(set) var sections: [any ShopSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var allShops: [ShopItem] {
        sections.compactMap { $0 as? ShopGridSection }.flatMap(\.shops)
    }

    private let fetchShopUseCase: FetchShopUseCase

    init(fetchShopUseCase: FetchShopUseCase) {
        self.fetchShopUseCase = fetchShopUseCase
    }

    func loadSections() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.isLoading = true
            self.errorMessage = nil

            do {
                self.sections = try await self.fetchShopUseCase.execute()
            } catch {
                self.errorMessage = error.localizedDescription
            }

            self.isLoading = false
        }
    }
}
