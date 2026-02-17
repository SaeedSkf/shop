import SwiftUI

struct BannerSectionView: View {

    let section: BannerSection

    @State private var currentBannerID: String?

    var body: some View {
        VStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(section.banners) { banner in
                        Color.clear
                            .overlay {
                                AsyncImage(url: banner.imageURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.quaternary)
                                }
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
            .aspectRatio(3, contentMode: .fit)

            pageIndicator
        }
        .onAppear {
            currentBannerID = section.banners.first?.id
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(section.banners) { banner in
                let isSelected = banner.id == currentBannerID
                Capsule()
                    .fill(isSelected ? Color.primaryPersian : Color.lightestGray)
                    .frame(width: isSelected ? 12 : 6, height: 6)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentBannerID)
    }
}
