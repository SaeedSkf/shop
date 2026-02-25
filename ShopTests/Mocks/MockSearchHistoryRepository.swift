import Foundation
@testable import Shop

final class MockSearchHistoryRepository: SearchHistoryRepository, @unchecked Sendable {

    var stubbedSearches: [String] = []
    private(set) var savedTerms: [String] = []
    private(set) var deletedTerms: [String] = []
    private(set) var deleteAllCallCount = 0

    func fetchRecentSearches() async -> [String] {
        stubbedSearches
    }

    func saveSearch(term: String) async {
        savedTerms.append(term)
        if !stubbedSearches.contains(term) {
            stubbedSearches.insert(term, at: 0)
        }
    }

    func deleteSearch(term: String) async {
        deletedTerms.append(term)
        stubbedSearches.removeAll { $0 == term }
    }

    func deleteAllSearches() async {
        deleteAllCallCount += 1
        stubbedSearches.removeAll()
    }
}
