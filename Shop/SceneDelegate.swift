import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let container = AppContainer()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let viewModel = container.resolve(ShopViewModel.self)
        let router = container.resolve(ShopRouter.self)
        let shopVC = ShopViewController(viewModel: viewModel, router: router)

        let navController = UINavigationController(rootViewController: shopVC)
        configureNavigationBarForRTL(navController.navigationBar)

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }

    private func configureNavigationBarForRTL(_ navigationBar: UINavigationBar) {
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        let backImage = UIImage(systemName: "chevron.right", withConfiguration: config)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = .label
    }
}
