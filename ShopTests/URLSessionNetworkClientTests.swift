import XCTest
@testable import Shop

final class URLSessionNetworkClientTests: XCTestCase {

    private var sut: URLSessionNetworkClient!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        sut = URLSessionNetworkClient(
            baseURL: URL(string: "https://api.example.com")!,
            session: session
        )
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testRequest_success_decodesResponse() async throws {
        let json = #"{"name":"test","value":42}"#
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.example.com")!,
                statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, json.data(using: .utf8)!)
        }

        let result: TestDecodable = try await sut.request(APIRequest(path: "/test"))
        XCTAssertEqual(result.name, "test")
        XCTAssertEqual(result.value, 42)
    }

    func testRequest_httpError_throwsAPIError() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.example.com")!,
                statusCode: 404, httpVersion: nil, headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let _: TestDecodable = try await sut.request(APIRequest(path: "/test"))
            XCTFail("Expected error")
        } catch let error as APIError {
            XCTAssertEqual(error, .httpError(statusCode: 404))
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func testRequest_invalidJSON_throwsDecodingError() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.example.com")!,
                statusCode: 200, httpVersion: nil, headerFields: nil
            )!
            return (response, "not json".data(using: .utf8)!)
        }

        do {
            let _: TestDecodable = try await sut.request(APIRequest(path: "/test"))
            XCTFail("Expected error")
        } catch let error as APIError {
            if case .decodingFailed = error { /* success */ }
            else { XCTFail("Expected decodingFailed, got \(error)") }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func testRequest_networkFailure_throwsNetworkError() async {
        MockURLProtocol.requestHandler = { _ in
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        }

        do {
            let _: TestDecodable = try await sut.request(APIRequest(path: "/test"))
            XCTFail("Expected error")
        } catch let error as APIError {
            if case .networkError = error { /* success */ }
            else { XCTFail("Expected networkError, got \(error)") }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    func testRequest_serverError_throwsHTTP500() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.example.com")!,
                statusCode: 500, httpVersion: nil, headerFields: nil
            )!
            return (response, Data())
        }

        do {
            let _: TestDecodable = try await sut.request(APIRequest(path: "/test"))
            XCTFail("Expected error")
        } catch let error as APIError {
            XCTAssertEqual(error, .httpError(statusCode: 500))
        } catch {
            XCTFail("Wrong error type")
        }
    }
}

// MARK: - Test Helpers

private struct TestDecodable: Decodable, Sendable {
    let name: String
    let value: Int
}

final class MockURLProtocol: URLProtocol, @unchecked Sendable {

    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: 0))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
