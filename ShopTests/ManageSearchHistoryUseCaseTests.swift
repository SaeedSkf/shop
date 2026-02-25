import XCTest
@testable import Shop

final class ManageSearchHistoryUseCaseTests: XCTestCase {

    private var sut: DefaultManageSearchHistoryUseCase!
    private var mockRepository: MockSearchHistoryRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockSearchHistoryRepository()
        sut = DefaultManageSearchHistoryUseCase(repository: mockRepository)
    }

    func testFetchRecentSearches_returnsRepositoryData() async {
        mockRepository.stubbedSearches = ["coffee", "pizza"]

        let result = await sut.fetchRecentSearches()

        XCTAssertEqual(result, ["coffee", "pizza"])
    }

    func testFetchRecentSearches_emptyRepository_returnsEmpty() async {
        let result = await sut.fetchRecentSearches()
        XCTAssertTrue(result.isEmpty)
    }

    func testDeleteSearch_delegatesToRepository() async {
        mockRepository.stubbedSearches = ["coffee", "pizza"]

        await sut.deleteSearch(term: "coffee")

        XCTAssertEqual(mockRepository.deletedTerms, ["coffee"])
    }

    func testDeleteAllSearches_delegatesToRepository() async {
        mockRepository.stubbedSearches = ["coffee", "pizza"]

        await sut.deleteAllSearches()

        XCTAssertEqual(mockRepository.deleteAllCallCount, 1)
    }
}
