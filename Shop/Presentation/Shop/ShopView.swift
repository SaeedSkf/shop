import SwiftUI

struct ShopView: View {
    
    @StateObject var viewModel: ShopViewModel
    
    var body: some View {
        NavigationStack {
            Text("ShopApp")
                .navigationTitle("Shop")
        }
    }
}

#Preview {
    ContentView()
}
