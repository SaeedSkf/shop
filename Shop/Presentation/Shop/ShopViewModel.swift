import Combine
import Foundation

@MainActor
final class ShopViewModel {

    @Published private(set) var sections: [any ShopSection] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var allShops: [ShopItem] {
        sections.compactMap { $0 as? ShopGridSection }.flatMap(\.shops)
    }

    private let fetchShopUseCase: FetchShopUseCase

    nonisolated init(fetchShopUseCase: FetchShopUseCase) {
        self.fetchShopUseCase = fetchShopUseCase
    }

    func loadSections() {
        Task { [weak self] in
            guard let self else { return }
            self.isLoading = true
            self.errorMessage = nil

            do {
                self.sections = try await self.fetchShopUseCase.execute()
            } catch {
                self.errorMessage = Self.userFacingMessage(from: error)
            }

            self.isLoading = false
        }
    }

    private static func userFacingMessage(from error: Error) -> String {
        let description = error.localizedDescription
        if let suggestion = (error as? LocalizedError)?.recoverySuggestion {
            return "\(description)\n\(suggestion)"
        }
        return description
    }
}
