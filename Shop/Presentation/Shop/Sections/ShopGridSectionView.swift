import SwiftUI

struct ShopGridSectionView: View {

    let section: ShopGridSection

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 4
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: section.title, actionTitleKey: "see_all", action: {})

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(section.shops) { shop in
                    shopItem(shop)
                }
            }
            .padding(.horizontal)
        }
    }

    private func shopItem(_ shop: ShopItem) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.deactiveGray)
                    .stroke(.deviderGray, lineWidth: 1)
                
                AsyncImage(url: shop.iconURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                } placeholder: {
                    ProgressView()
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text(shop.title)
                .font(.appSubtitle1)
                .foregroundStyle(.darkGray)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}
