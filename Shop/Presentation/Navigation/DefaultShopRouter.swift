import UIKit

final class DefaultShopRouter: ShopRouter {

    private let searchShopsUseCase: SearchShopsUseCase
    private let manageHistoryUseCase: ManageSearchHistoryUseCase

    init(searchShopsUseCase: SearchShopsUseCase, manageHistoryUseCase: ManageSearchHistoryUseCase) {
        self.searchShopsUseCase = searchShopsUseCase
        self.manageHistoryUseCase = manageHistoryUseCase
    }

    @MainActor
    func showSearch(from viewController: UIViewController, shops: [ShopItem]) {
        let viewModel = SearchViewModel(
            shops: shops,
            searchShopsUseCase: searchShopsUseCase,
            manageHistoryUseCase: manageHistoryUseCase
        )
        let searchVC = SearchViewController(viewModel: viewModel)
        viewController.navigationController?.pushViewController(searchVC, animated: true)
    }
}
