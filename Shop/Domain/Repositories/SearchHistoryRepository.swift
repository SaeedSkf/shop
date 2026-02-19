import Foundation

protocol SearchHistoryRepository: Sendable {
    func fetchRecentSearches() async -> [String]
    func saveSearch(term: String) async
    func deleteSearch(term: String) async
    func deleteAllSearches() async
}
