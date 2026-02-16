import Foundation

protocol NetworkClient {
    func request<T: Decodable>(_ apiRequest: APIRequest) async throws -> T
}
