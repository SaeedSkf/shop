import SwiftUI

struct FixedBannerSectionView: View {

    let section: FixedBannerSection

    private let spacing: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(.appHeadline)
                .padding(.horizontal)

            Group {
                switch section.banners.count {
                case 1:
                    oneItemLayout
                case 2:
                    twoItemsLayout
                case 3:
                    threeItemsLayout
                case 4:
                    fourItemsLayout
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - 1 Item: Full Width

    private var oneItemLayout: some View {
        bannerImage(section.banners[0])
            .aspectRatio(2.5, contentMode: .fit)
    }

    // MARK: - 2 Items: Side by Side (50% - 50%)

    private var twoItemsLayout: some View {
        HStack(spacing: spacing) {
            bannerImage(section.banners[0])
            bannerImage(section.banners[1])
        }
        .aspectRatio(2.5, contentMode: .fit)
    }

    // MARK: - 3 Items: Large right + two stacked left

    private let totalHeight: CGFloat = 260

    private var threeItemsLayout: some View {
        HStack(spacing: spacing) {
            bannerImage(section.banners[0])
                .frame(height: totalHeight)

            VStack(spacing: spacing) {
                bannerImage(section.banners[1])
                    .frame(height: (totalHeight - spacing) / 2)
                bannerImage(section.banners[2])
                    .frame(height: (totalHeight - spacing) / 2)
            }
        }
        .frame(height: totalHeight)
    }

    // MARK: - 4 Items: 2x2 Grid

    private var fourItemsLayout: some View {
        let columns = [
            GridItem(.flexible(), spacing: spacing),
            GridItem(.flexible(), spacing: spacing)
        ]

        return LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(section.banners) { banner in
                bannerImage(banner)
                    .aspectRatio(1.5, contentMode: .fit)
            }
        }
    }

    // MARK: - Shared Banner Image

    private func bannerImage(_ banner: Banner) -> some View {
        AsyncImage(url: banner.imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary)
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
