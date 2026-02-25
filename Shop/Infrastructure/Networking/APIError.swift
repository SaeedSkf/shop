import Foundation

enum APIError: Error, Equatable, @unchecked Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case networkError(Error)

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse):
            return true
        case (.httpError(let l), .httpError(let r)):
            return l == r
        case (.decodingFailed, .decodingFailed),
             (.networkError, .networkError):
            return true
        default:
            return false
        }
    }
}

extension APIError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("error_invalid_url", comment: "")
        case .invalidResponse:
            return NSLocalizedString("error_invalid_response", comment: "")
        case .httpError(let statusCode):
            return httpErrorMessage(for: statusCode)
        case .decodingFailed:
            return NSLocalizedString("error_decoding_failed", comment: "")
        case .networkError(let underlying):
            return networkErrorMessage(for: underlying)
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return NSLocalizedString("error_recovery_check_connection", comment: "")
        case .httpError(let code) where (500...599).contains(code):
            return NSLocalizedString("error_recovery_try_later", comment: "")
        default:
            return NSLocalizedString("error_recovery_try_again", comment: "")
        }
    }

    private func httpErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 401, 403:
            return NSLocalizedString("error_unauthorized", comment: "")
        case 404:
            return NSLocalizedString("error_not_found", comment: "")
        case 429:
            return NSLocalizedString("error_too_many_requests", comment: "")
        case 500...599:
            return NSLocalizedString("error_server", comment: "")
        default:
            return String(
                format: NSLocalizedString("error_http_generic", comment: ""),
                statusCode
            )
        }
    }

    private func networkErrorMessage(for error: Error) -> String {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                return NSLocalizedString("error_no_internet", comment: "")
            case NSURLErrorTimedOut:
                return NSLocalizedString("error_timeout", comment: "")
            case NSURLErrorCancelled:
                return NSLocalizedString("error_cancelled", comment: "")
            default:
                break
            }
        }
        return NSLocalizedString("error_network_generic", comment: "")
    }
}
