import XCTest
@testable import Shop

final class DefaultShopRepositoryTests: XCTestCase {

    private var sut: DefaultShopRepository!
    private var mockRemoteDataSource: MockShopRemoteDataSource!
    private var sectionFactory: DefaultSectionFactory!

    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockShopRemoteDataSource()
        sectionFactory = DefaultSectionFactory()
        sut = DefaultShopRepository(
            remoteDataSource: mockRemoteDataSource,
            sectionFactory: sectionFactory
        )
    }

    func testFetchSections_fetchesAndMaps() async throws {
        mockRemoteDataSource.stubbedResponse = TestFixtures.makeShopResponseDTO()

        let sections = try await sut.fetchSections()

        XCTAssertEqual(mockRemoteDataSource.fetchCallCount, 1)
        XCTAssertFalse(sections.isEmpty)
    }

    func testFetchSections_propagatesNetworkError() async {
        mockRemoteDataSource.stubbedError = APIError.networkError(
            NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)
        )

        do {
            _ = try await sut.fetchSections()
            XCTFail("Expected error")
        } catch let error as APIError {
            XCTAssertEqual(error, .networkError(NSError()))
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
}
