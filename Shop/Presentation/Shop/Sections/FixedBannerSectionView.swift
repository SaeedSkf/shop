import SwiftUI

struct FixedBannerSectionView: View {

    let section: FixedBannerSection

    private let spacing: CGFloat = 8

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: section.title)

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

    private var threeItemsLayout: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let halfWidth = (totalWidth - spacing) / 2
            let totalHeight = geometry.size.height
            let halfHeight = (totalHeight - spacing) / 2

            HStack(spacing: spacing) {
                bannerImage(section.banners[0])
                    .frame(width: halfWidth, height: totalHeight)

                VStack(spacing: spacing) {
                    bannerImage(section.banners[1])
                        .frame(width: halfWidth, height: halfHeight)
                    bannerImage(section.banners[2])
                        .frame(width: halfWidth, height: halfHeight)
                }
            }
        }
        .aspectRatio(1.2, contentMode: .fit)
    }

    // MARK: - 4 Items: 2x2 Grid

    private var fourItemsLayout: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let halfWidth = (totalWidth - spacing) / 2
            let totalHeight = geometry.size.height
            let halfHeight = (totalHeight - spacing) / 2

            VStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    bannerImage(section.banners[0])
                        .frame(width: halfWidth, height: halfHeight)
                    bannerImage(section.banners[1])
                        .frame(width: halfWidth, height: halfHeight)
                }
                HStack(spacing: spacing) {
                    bannerImage(section.banners[2])
                        .frame(width: halfWidth, height: halfHeight)
                    bannerImage(section.banners[3])
                        .frame(width: halfWidth, height: halfHeight)
                }
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
    }

    // MARK: - Shared Banner Image

    private func bannerImage(_ banner: Banner) -> some View {
        Color.clear
            .overlay {
                AsyncImage(url: banner.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.primaryLight)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
