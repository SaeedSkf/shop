import SwiftData
import Swinject

struct SearchAssembly: Assembly {

    func assemble(container: Container) {
        container.register(SearchHistoryLocalDataSource.self) { resolver in
            let modelContainer = resolver.resolve(ModelContainer.self)!
            return DefaultDataSearchHistoryLocalDataSource(modelContainer: modelContainer)
        }.inObjectScope(.container)

        container.register(SearchHistoryRepository.self) { resolver in
            let dataSource = resolver.resolve(SearchHistoryLocalDataSource.self)!
            return DefaultSearchHistoryRepository(localDataSource: dataSource)
        }

        container.register(SearchShopsUseCase.self) { resolver in
            let repository = resolver.resolve(SearchHistoryRepository.self)!
            return DefaultSearchShopsUseCase(historyRepository: repository)
        }

        container.register(ManageSearchHistoryUseCase.self) { resolver in
            let repository = resolver.resolve(SearchHistoryRepository.self)!
            return DefaultManageSearchHistoryUseCase(repository: repository)
        }
    }
}
