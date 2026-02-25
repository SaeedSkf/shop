import Foundation

protocol NetworkClient: Sendable {
    func request<T: Decodable & Sendable>(_ apiRequest: APIRequest) async throws -> T
}
