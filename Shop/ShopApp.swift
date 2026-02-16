import SwiftUI

@main
struct ShopApp: App {
    private let container = AppContainer()
    
    var body: some Scene {
        WindowGroup {
            ShopView(viewModel: container.resolve(ShopViewModel.self))
        }
    }
}
