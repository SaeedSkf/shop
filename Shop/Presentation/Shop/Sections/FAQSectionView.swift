import SwiftUI

struct FAQSectionView: View {

    let section: FAQSection

    @State private var expandedItemID: String?

    var body: some View {
        VStack(spacing: 16) {
            SectionHeaderView(title: section.title)

            ForEach(section.items) { item in
                faqRow(item)

                if item.id != section.items.last?.id {
                    Divider()
                }
            }
            .padding(.horizontal)
        }
    }

    private func faqRow(_ item: FAQItem) -> some View {
        let isExpanded = expandedItemID == item.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    expandedItemID = isExpanded ? nil : item.id
                }
            } label: {
                HStack {
                    Text(item.title)
                        .font(.appSubheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                    
                }
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Text(item.answer)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
