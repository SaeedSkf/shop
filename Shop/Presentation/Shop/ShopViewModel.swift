import Combine
import Foundation

final class ShopViewModel: ObservableObject {

    private let fetchShopUseCase: FetchShopUseCase

    init(fetchShopUseCase: FetchShopUseCase) {
        self.fetchShopUseCase = fetchShopUseCase
    }
}
