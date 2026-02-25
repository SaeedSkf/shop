import XCTest
@testable import Shop

final class ImageLoaderTests: XCTestCase {

    private var sut: ImageLoader!

    override func setUp() {
        super.setUp()
        sut = ImageLoader()
    }

    func testImage_returnsNilForInvalidImageData() async throws {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://example.com")!,
                statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, "not an image".data(using: .utf8)!)
        }

        let url = URL(string: "https://example.com/bad-image.png")!
        let image = try await sut.image(for: url)
        XCTAssertNil(image)
    }

    func testCancel_cancelsInflightTask() async {
        let url = URL(string: "https://example.com/slow-image.png")!

        await sut.cancel(for: url)
    }
}
