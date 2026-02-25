import Combine
import XCTest
@testable import Shop

@MainActor
final class ShopViewModelTests: XCTestCase {

    private var sut: ShopViewModel!
    private var mockUseCase: MockFetchShopUseCase!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchShopUseCase()
        sut = ShopViewModel(fetchShopUseCase: mockUseCase)
        cancellables = []
    }

    func testInitialState() {
        XCTAssertTrue(sut.sections.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadSections_success_publishesSections() async {
        let section = TestFixtures.makeShopGridSection()
        mockUseCase.stubbedSections = [section]

        let expectation = expectation(description: "sections published")
        sut.$sections
            .dropFirst()
            .first { !$0.isEmpty }
            .sink { sections in
                XCTAssertEqual(sections.count, 1)
                XCTAssertEqual(sections[0].id, section.id)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadSections()
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testLoadSections_success_clearsError() async {
        mockUseCase.stubbedSections = [TestFixtures.makeShopGridSection()]

        let expectation = expectation(description: "loading finishes")
        sut.$isLoading
            .dropFirst(2)
            .first { !$0 }
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.loadSections()
        await fulfillment(of: [expectation], timeout: 2)
        XCTAssertNil(sut.errorMessage)
    }

    func testLoadSections_failure_publishesErrorMessage() async {
        mockUseCase.stubbedError = APIError.networkError(
            NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        )

        let expectation = expectation(description: "error published")
        sut.$errorMessage
            .dropFirst()
            .compactMap { $0 }
            .first()
            .sink { message in
                XCTAssertFalse(message.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadSections()
        await fulfillment(of: [expectation], timeout: 2)
    }

    func testLoadSections_setsLoadingDuringFetch() async {
        mockUseCase.stubbedSections = []

        var loadingStates: [Bool] = []
        let expectation = expectation(description: "loading completes")

        sut.$isLoading
            .dropFirst()
            .prefix(2)
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 2 { expectation.fulfill() }
            }
            .store(in: &cancellables)

        sut.loadSections()
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(loadingStates, [true, false])
    }

    func testAllShops_extractsShopsFromGridSections() async {
        let shops = [
            TestFixtures.makeShopItem(id: "1"),
            TestFixtures.makeShopItem(id: "2"),
        ]
        mockUseCase.stubbedSections = [
            TestFixtures.makeShopGridSection(shops: shops),
            TestFixtures.makeBannerSection(),
        ]

        let expectation = expectation(description: "loaded")
        sut.$sections
            .dropFirst()
            .first { !$0.isEmpty }
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.loadSections()
        await fulfillment(of: [expectation], timeout: 2)

        XCTAssertEqual(sut.allShops.count, 2)
        XCTAssertEqual(sut.allShops.map(\.id), ["1", "2"])
    }

    func testLoadSections_errorIncludesRecoverySuggestion() async {
        mockUseCase.stubbedError = APIError.networkError(
            NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        )

        let expectation = expectation(description: "error published")
        sut.$errorMessage
            .dropFirst()
            .compactMap { $0 }
            .first()
            .sink { message in
                XCTAssertTrue(message.contains("\n"), "Should include recovery suggestion on new line")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.loadSections()
        await fulfillment(of: [expectation], timeout: 2)
    }
}
