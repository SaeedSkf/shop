import Foundation

final class DefaultShopRepository: ShopRepository {

    private let remoteDataSource: ShopRemoteDataSource
    private let sectionFactory: SectionFactory

    init(remoteDataSource: ShopRemoteDataSource, sectionFactory: SectionFactory) {
        self.remoteDataSource = remoteDataSource
        self.sectionFactory = sectionFactory
    }

    func fetchSections() async throws -> [any ShopSection] {
        let response = try await remoteDataSource.fetchShopResponse()
        return sectionFactory.makeSections(from: response)
    }
}
