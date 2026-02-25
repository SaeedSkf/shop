import XCTest
@testable import Shop

final class FetchShopUseCaseTests: XCTestCase {

    private var sut: DefaultFetchShopUseCase!
    private var mockRepository: MockShopRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockShopRepository()
        sut = DefaultFetchShopUseCase(repository: mockRepository)
    }

    func testExecute_returnsSectionsFromRepository() async throws {
        let expected: [any ShopSection] = [
            TestFixtures.makeShopGridSection(),
            TestFixtures.makeBannerSection(),
        ]
        mockRepository.stubbedSections = expected

        let result = try await sut.execute()

        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, expected[0].id)
        XCTAssertEqual(result[1].id, expected[1].id)
    }

    func testExecute_propagatesError() async {
        mockRepository.stubbedError = APIError.networkError(
            NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        )

        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }

    func testExecute_callsRepositoryOnce() async throws {
        mockRepository.stubbedSections = []
        _ = try await sut.execute()
        XCTAssertEqual(mockRepository.fetchCallCount, 1)
    }
}
