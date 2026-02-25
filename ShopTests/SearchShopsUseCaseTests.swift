import XCTest
@testable import Shop

final class SearchShopsUseCaseTests: XCTestCase {

    private var sut: DefaultSearchShopsUseCase!
    private var mockRepository: MockSearchHistoryRepository!

    private let shops = [
        TestFixtures.makeShopItem(id: "1", title: "Coffee House", tags: ["coffee", "drinks"]),
        TestFixtures.makeShopItem(id: "2", title: "Pizza Place", tags: ["pizza", "food"]),
        TestFixtures.makeShopItem(id: "3", title: "Book Store", tags: ["books", "stationery"]),
    ]

    override func setUp() {
        super.setUp()
        mockRepository = MockSearchHistoryRepository()
        sut = DefaultSearchShopsUseCase(historyRepository: mockRepository)
    }

    func testExecute_queryTooShort_returnsEmpty() async {
        let results = await sut.execute(query: "ab", in: shops)
        XCTAssertTrue(results.isEmpty)
    }

    func testExecute_queryMatchesTitle_returnsMatches() async {
        let results = await sut.execute(query: "coffee", in: shops)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, "1")
    }

    func testExecute_queryMatchesTag_returnsMatches() async {
        let results = await sut.execute(query: "books", in: shops)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, "3")
    }

    func testExecute_caseInsensitiveMatch() async {
        let results = await sut.execute(query: "PIZZA", in: shops)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, "2")
    }

    func testExecute_noMatch_returnsEmpty() async {
        let results = await sut.execute(query: "sushi", in: shops)
        XCTAssertTrue(results.isEmpty)
    }

    func testExecute_savesSearchWhenResultsFound() async {
        _ = await sut.execute(query: "coffee", in: shops)
        XCTAssertEqual(mockRepository.savedTerms, ["coffee"])
    }

    func testExecute_doesNotSaveSearchWhenNoResults() async {
        _ = await sut.execute(query: "sushi", in: shops)
        XCTAssertTrue(mockRepository.savedTerms.isEmpty)
    }

    func testExecute_whitespaceOnlyQuery_returnsEmpty() async {
        let results = await sut.execute(query: "   ", in: shops)
        XCTAssertTrue(results.isEmpty)
    }

    func testExecute_trimsWhitespace() async {
        let results = await sut.execute(query: "  coffee  ", in: shops)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, "1")
    }
}
