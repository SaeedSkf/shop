import SwiftUI

enum AppFont: String {
    case regular = "IRANYekanXFaNum-Regular"
    case bold = "IRANYekanXFaNum-Bold"
}

extension Font {

    static func appFont(_ weight: AppFont = .regular, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }

    // MARK: - Large Title

    static var appLargeTitle: Font {
        appFont(.bold, size: 28)
    }

    // MARK: - Title

    static var appTitle: Font {
        appFont(.bold, size: 22)
    }

    static var appTitle2: Font {
        appFont(.bold, size: 20)
    }

    static var appTitle3: Font {
        appFont(.bold, size: 18)
    }
    
    static var appSubtitle1: Font {
        appFont(.bold, size: 12)
    }

    // MARK: - Headline / Subheadline

    static var appHeadline: Font {
        appFont(.bold, size: 16)
    }

    static var appSubheadline: Font {
        appFont(.regular, size: 14)
    }

    // MARK: - Body

    static var appBody: Font {
        appFont(.regular, size: 16)
    }

    static var appBodyBold: Font {
        appFont(.bold, size: 16)
    }

    // MARK: - Callout / Footnote

    static var appCallout: Font {
        appFont(.regular, size: 15)
    }

    static var appFootnote: Font {
        appFont(.regular, size: 13)
    }

    // MARK: - Caption

    static var appCaption: Font {
        appFont(.regular, size: 12)
    }

    static var appCaption2: Font {
        appFont(.regular, size: 11)
    }
}
