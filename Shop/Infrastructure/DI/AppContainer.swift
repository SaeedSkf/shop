import Foundation
import SwiftData
import Swinject

final class AppContainer {

    private let container: Container

    init() {
        container = Container()
        registerNetworking()
        registerStorage()
        registerFeatures()
    }

    // MARK: - Core

    private func registerNetworking() {
        container.register(NetworkClient.self) { _ in
            URLSessionNetworkClient(baseURL: AppConfig.baseURL)
        }.inObjectScope(.container)
    }

    private func registerStorage() {
        container.register(ModelContainer.self) { _ in
            ModelContainer.makeAppContainer()
        }.inObjectScope(.container)
    }

    // MARK: - Features

    private func registerFeatures() {
        ShopAssembly().assemble(container: container)
        SearchAssembly().assemble(container: container)
    }
}


extension AppContainer {
    func resolve<Service>(_ type: Service.Type) -> Service {
        guard let service = container.resolve(type) else {
            fatalError("Dependency \(type) not registered.")
        }
        return service
    }
}
