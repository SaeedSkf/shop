import Foundation

protocol ManageSearchHistoryUseCase {
    func fetchRecentSearches() async -> [String]
    func deleteSearch(term: String) async
    func deleteAllSearches() async
}

final class DefaultManageSearchHistoryUseCase: ManageSearchHistoryUseCase {

    private let repository: SearchHistoryRepository

    init(repository: SearchHistoryRepository) {
        self.repository = repository
    }

    func fetchRecentSearches() async -> [String] {
        await repository.fetchRecentSearches()
    }

    func deleteSearch(term: String) async {
        await repository.deleteSearch(term: term)
    }

    func deleteAllSearches() async {
        await repository.deleteAllSearches()
    }
}
