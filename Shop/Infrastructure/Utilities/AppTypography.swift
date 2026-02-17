import UIKit

enum AppFont: String {
    case regular = "IRANYekanXFaNum-Regular"
    case bold = "IRANYekanXFaNum-Bold"
}

extension UIFont {

    static func appFont(_ weight: AppFont = .regular, size: CGFloat) -> UIFont {
        UIFont(name: weight.rawValue, size: size) ?? .systemFont(ofSize: size)
    }

    // MARK: - Large Title

    static var appLargeTitle: UIFont { appFont(.bold, size: 28) }

    // MARK: - Title

    static var appTitle: UIFont { appFont(.bold, size: 22) }
    static var appTitle2: UIFont { appFont(.bold, size: 20) }
    static var appTitle3: UIFont { appFont(.bold, size: 18) }
    static var appSubtitle1: UIFont { appFont(.bold, size: 12) }

    // MARK: - Headline / Subheadline

    static var appHeadline: UIFont { appFont(.bold, size: 16) }
    static var appSubheadline: UIFont { appFont(.regular, size: 14) }

    // MARK: - Body

    static var appBody: UIFont { appFont(.regular, size: 16) }
    static var appBodyBold: UIFont { appFont(.bold, size: 16) }

    // MARK: - Callout / Footnote

    static var appCallout: UIFont { appFont(.regular, size: 15) }
    static var appFootnote: UIFont { appFont(.regular, size: 13) }

    // MARK: - Caption

    static var appCaption: UIFont { appFont(.regular, size: 12) }
    static var appCaption2: UIFont { appFont(.regular, size: 11) }
}
