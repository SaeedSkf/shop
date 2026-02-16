import Foundation
import Swinject

final class AppContainer {

    private let container: Container

    init() {
        container = Container()
        registerNetworking()
        registerFeatures()
    }

    // MARK: - Core

    private func registerNetworking() {
        container.register(NetworkClient.self) { _ in
            URLSessionNetworkClient(baseURL: AppConfig.baseURL)
        }.inObjectScope(.container)
    }
    
    // MARK: - Features

    private func registerFeatures() {
        ShopAssembly().assemble(container: container)
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
