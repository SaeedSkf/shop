import Foundation

protocol SearchShopsUseCase {
    func execute(query: String, in shops: [ShopItem]) async -> [ShopItem]
}

final class DefaultSearchShopsUseCase: SearchShopsUseCase {

    private let historyRepository: SearchHistoryRepository
    private static let minCharacters = 3

    init(historyRepository: SearchHistoryRepository) {
        self.historyRepository = historyRepository
    }

    func execute(query: String, in shops: [ShopItem]) async -> [ShopItem] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= Self.minCharacters else { return [] }

        let lowered = trimmed.lowercased()

        let results = shops.filter { shop in
            shop.title.lowercased().contains(lowered) ||
            shop.tags.contains { $0.lowercased().contains(lowered) }
        }

        if !results.isEmpty {
            await historyRepository.saveSearch(term: trimmed)
        }

        return results
    }
}
