import SwiftUI

struct CategorySectionView: View {

    let section: CategorySection

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeaderView(title: section.title, actionTitleKey: "see_all", action: {})

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
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
            ZStack(alignment: .center) {
                Circle()
                    .fill(.primaryLightest)
                    .stroke(.primaryLight, lineWidth: 1)
                
                AsyncImage(url: category.iconURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
            }
            .frame(height: 72)
            
            Text(category.title)
                .font(.appSubtitle1)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(width: 72)
    }
}

