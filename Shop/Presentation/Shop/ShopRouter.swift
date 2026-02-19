import UIKit

protocol ShopRouter: AnyObject {
    @MainActor func showSearch(from viewController: UIViewController, shops: [ShopItem])
}
