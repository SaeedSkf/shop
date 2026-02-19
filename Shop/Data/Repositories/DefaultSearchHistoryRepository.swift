import Foundation

final class DefaultSearchHistoryRepository: SearchHistoryRepository {

    private let localDataSource: SearchHistoryLocalDataSource

    init(localDataSource: SearchHistoryLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func fetchRecentSearches() async -> [String] {
        await localDataSource.fetchAll()
    }

    func saveSearch(term: String) async {
        await localDataSource.save(term: term)
    }

    func deleteSearch(term: String) async {
        await localDataSource.delete(term: term)
    }

    func deleteAllSearches() async {
        await localDataSource.deleteAll()
    }
}
