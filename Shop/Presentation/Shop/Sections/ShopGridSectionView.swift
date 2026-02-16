import SwiftUI

struct ShopGridSectionView: View {

    let section: ShopGridSection

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 4
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.appHeadline)
                .padding(.horizontal)

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
            AsyncImage(url: shop.iconURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(shop.title)
                .font(.appCaption2)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
    }
}
