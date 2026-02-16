import SwiftUI

struct SectionHeaderView: View {
    let title: String
    let actionTitleKey: LocalizedStringKey?
    var action: (() -> Void)?

    init(title: String, actionTitleKey: LocalizedStringKey? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.actionTitleKey = actionTitleKey
        self.action = action
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.appHeadline)
                .foregroundStyle(.boldGray)
                .padding(.horizontal)

            Spacer()

            if let action, let actionTitleKey {
                Button(action: action) {
                    Text(actionTitleKey)
                        .font(.appCaption)
                        .foregroundStyle(.primaryPersian)
                        .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
