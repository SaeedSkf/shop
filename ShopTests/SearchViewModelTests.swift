import Combine
import XCTest
@testable import Shop

final class MockSearchShopsUseCase: SearchShopsUseCase, @unchecked Sendable {

    var stubbedResults: [ShopItem] = []
    private(set) var executedQueries: [String] = []

    func execute(query: String, in shops: [ShopItem]) async -> [ShopItem] {
        executedQueries.append(query)
        return stubbedResults
    }
}

final class MockManageHistoryUseCase: ManageSearchHistoryUseCase, @unchecked Sendable {

    var stubbedSearches: [String] = []
    private(set) var deletedTerms: [String] = []
    private(set) var deleteAllCallCount = 0

    func fetchRecentSearches() async -> [String] {
        stubbedSearches
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

@MainActor
final class SearchViewModelTests: XCTestCase {

    private var sut: SearchViewModel!
    private var mockSearchUseCase: MockSearchShopsUseCase!
    private var mockHistoryUseCase: MockManageHistoryUseCase!
    private var cancellables: Set<AnyCancellable>!

    private let shops = [
        TestFixtures.makeShopItem(id: "1", title: "Coffee House", tags: ["coffee"]),
        TestFixtures.makeShopItem(id: "2", title: "Pizza Place", tags: ["pizza"]),
    ]

    override func setUp() {
        super.setUp()
        mockSearchUseCase = MockSearchShopsUseCase()
        mockHistoryUseCase = MockManageHistoryUseCase()
        cancellables = []
    }

    private func makeSUT(recentSearches: [String] = []) -> SearchViewModel {
        mockHistoryUseCase.stubbedSearches = recentSearches
        return SearchViewModel(
            shops: shops,
            searchShopsUseCase: mockSearchUseCase,
            manageHistoryUseCase: mockHistoryUseCase
        )
    }

    func testInitialState() {
        sut = makeSUT()
        XCTAssertEqual(sut.searchText, "")
        XCTAssertTrue(sut.searchResults.isEmpty)
        XCTAssertFalse(sut.showEmptyState)
    }

    func testLoadRecentSearches_populatesList() async {
        sut = makeSUT(recentSearches: ["coffee", "pizza"])

        let expectation = expectation(description: "recent searches loaded")
        sut.$recentSearches
            .dropFirst()
            .first { !$0.isEmpty }
            .sink { searches in
                XCTAssertEqual(searches, ["coffee", "pizza"])
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadRecentSearches()
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testDeleteSearch_removesFromList() async {
        sut = makeSUT(recentSearches: ["coffee", "pizza"])

        let expectation = expectation(description: "search deleted")
        sut.$recentSearches
            .dropFirst()
            .first()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.deleteSearch(term: "coffee")
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(mockHistoryUseCase.deletedTerms, ["coffee"])
    }

    func testDeleteAllSearches_clearsAll() async {
        sut = makeSUT(recentSearches: ["coffee", "pizza"])

        let expectation = expectation(description: "all deleted")
        sut.$recentSearches
            .dropFirst()
            .first { $0.isEmpty }
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.deleteAllSearches()
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(mockHistoryUseCase.deleteAllCallCount, 1)
        XCTAssertTrue(sut.recentSearches.isEmpty)
    }

    func testSelectRecentSearch_updatesSearchText() {
        sut = makeSUT()
        sut.selectRecentSearch("coffee")
        XCTAssertEqual(sut.searchText, "coffee")
    }
}
