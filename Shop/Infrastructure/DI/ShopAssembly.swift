import Swinject

struct ShopAssembly: Assembly {

    func assemble(container: Container) {
        container.register(ShopRemoteDataSource.self) { resolver in
            let client = resolver.resolve(NetworkClient.self)!
            return DefaultShopRemoteDataSource(networkClient: client)
        }

        container.register(SectionFactory.self) { _ in
            DefaultSectionFactory()
        }

        container.register(ShopRepository.self) { resolver in
            let remote = resolver.resolve(ShopRemoteDataSource.self)!
            let factory = resolver.resolve(SectionFactory.self)!
            return DefaultShopRepository(remoteDataSource: remote, sectionFactory: factory)
        }

        container.register(FetchShopUseCase.self) { resolver in
            let repository = resolver.resolve(ShopRepository.self)!
            return DefaultFetchShopUseCase(repository: repository)
        }
        
        container.register(ShopRouter.self) { resolver in
            let searchUseCase = resolver.resolve(SearchShopsUseCase.self)!
            let historyUseCase = resolver.resolve(ManageSearchHistoryUseCase.self)!
            return DefaultShopRouter(searchShopsUseCase: searchUseCase, manageHistoryUseCase: historyUseCase)
        }

        container.register(ShopViewModel.self) { resolver in
            let useCase = resolver.resolve(FetchShopUseCase.self)!
            return ShopViewModel(fetchShopUseCase: useCase)
        }
    }
}
