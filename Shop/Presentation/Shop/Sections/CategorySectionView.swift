import SwiftUI

struct CategorySectionView: View {

    let section: CategorySection

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.appHeadline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(section.categories) { category in
                        categoryItem(category)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private func categoryItem(_ category: Category) -> some View {
        VStack(spacing: 8) {
            AsyncImage(url: category.iconURL) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Circle()
                    .fill(.quaternary)
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())

            Text(category.title)
                .font(.appCaption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 72)
    }
}
