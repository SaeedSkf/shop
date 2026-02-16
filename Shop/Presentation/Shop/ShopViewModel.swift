import Combine
import Foundation

final class ShopViewModel: ObservableObject {

    @Published private(set) var sections: [any ShopSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let fetchShopUseCase: FetchShopUseCase

    init(fetchShopUseCase: FetchShopUseCase) {
        self.fetchShopUseCase = fetchShopUseCase
    }

    func loadSections() async {
        isLoading = true
        errorMessage = nil

        do {
            sections = try await fetchShopUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
