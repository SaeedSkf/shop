import UIKit

protocol ShopRouter: AnyObject, Sendable {
    @MainActor func showSearch(from viewController: UIViewController, shops: [ShopItem])
}
