import SwiftUI

struct BannerSectionView: View {

    let section: BannerSection

    @State private var currentBannerID: String?

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(section.banners) { banner in
                        AsyncImage(url: banner.imageURL) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.quaternary)
                                .aspectRatio(2.5, contentMode: .fit)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $currentBannerID)

            pageIndicator
        }
        .onAppear {
            currentBannerID = section.banners.first?.id
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(section.banners) { banner in
                Circle()
                    .fill(banner.id == currentBannerID ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 7, height: 7)
            }
        }
    }
}
