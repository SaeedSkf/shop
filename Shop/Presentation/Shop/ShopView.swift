import SwiftUI

struct ShopView: View {

    @StateObject var viewModel: ShopViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("فروشگاه")
        }
        .environment(\.layoutDirection, .rightToLeft)
        .task {
            await viewModel.loadSections()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            errorView(message: errorMessage)
        } else {
            sectionsList
        }
    }

    private var sectionsList: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.sections, id: \.id) { section in
                    sectionView(for: section)
                }
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder
    private func sectionView(for section: any ShopSection) -> some View {
        switch section {
        case let section as CategorySection:
            CategorySectionView(section: section)
        case let section as BannerSection:
            BannerSectionView(section: section)
        case let section as ShopGridSection:
            ShopGridSectionView(section: section)
        case let section as FixedBannerSection:
            FixedBannerSectionView(section: section)
        default:
            EmptyView()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.appFont(.bold, size: 48))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.appSubheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                Task { await viewModel.loadSections() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
