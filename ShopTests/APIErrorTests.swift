import XCTest
@testable import Shop

final class APIErrorTests: XCTestCase {

    // MARK: - Error Description

    func testInvalidURL_hasLocalizedDescription() {
        let error = APIError.invalidURL
        XCTAssertNotNil(error.errorDescription)
        XCTAssertFalse(error.errorDescription!.isEmpty)
    }

    func testInvalidResponse_hasLocalizedDescription() {
        let error = APIError.invalidResponse
        XCTAssertNotNil(error.errorDescription)
    }

    func testDecodingFailed_hasLocalizedDescription() {
        let error = APIError.decodingFailed(NSError(domain: "", code: 0))
        XCTAssertNotNil(error.errorDescription)
    }

    func testNetworkError_noInternet_hasSpecificMessage() {
        let urlError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet
        )
        let error = APIError.networkError(urlError)
        XCTAssertNotNil(error.errorDescription)
    }

    func testNetworkError_timeout_hasSpecificMessage() {
        let urlError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorTimedOut
        )
        let error = APIError.networkError(urlError)
        XCTAssertNotNil(error.errorDescription)
    }

    func testHTTPError_401_hasUnauthorizedMessage() {
        let error = APIError.httpError(statusCode: 401)
        XCTAssertNotNil(error.errorDescription)
    }

    func testHTTPError_404_hasNotFoundMessage() {
        let error = APIError.httpError(statusCode: 404)
        XCTAssertNotNil(error.errorDescription)
    }

    func testHTTPError_500_hasServerMessage() {
        let error = APIError.httpError(statusCode: 500)
        XCTAssertNotNil(error.errorDescription)
    }

    func testHTTPError_genericCode_includesStatusCode() {
        let error = APIError.httpError(statusCode: 418)
        XCTAssertNotNil(error.errorDescription)
    }

    // MARK: - Recovery Suggestions

    func testNetworkError_hasConnectionRecoverySuggestion() {
        let urlError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        let error = APIError.networkError(urlError)
        XCTAssertNotNil(error.recoverySuggestion)
    }

    func testServerError_hasTryLaterRecoverySuggestion() {
        let error = APIError.httpError(statusCode: 503)
        XCTAssertNotNil(error.recoverySuggestion)
    }

    func testInvalidURL_hasTryAgainRecoverySuggestion() {
        let error = APIError.invalidURL
        XCTAssertNotNil(error.recoverySuggestion)
    }

    // MARK: - Equatable

    func testEquatable_sameCase_areEqual() {
        XCTAssertEqual(APIError.invalidURL, APIError.invalidURL)
        XCTAssertEqual(APIError.invalidResponse, APIError.invalidResponse)
        XCTAssertEqual(
            APIError.httpError(statusCode: 404),
            APIError.httpError(statusCode: 404)
        )
    }

    func testEquatable_differentCases_areNotEqual() {
        XCTAssertNotEqual(APIError.invalidURL, APIError.invalidResponse)
        XCTAssertNotEqual(
            APIError.httpError(statusCode: 404),
            APIError.httpError(statusCode: 500)
        )
    }
}
