
import SwiftUI
import UIKit



enum RestyleColors {
    static let lime = Color(hex: 0xC0FE0F)
    static let coral = Color(hex: 0xF74653)
    static let blue = Color(hex: 0x4377FE)
    static let pink = Color(hex: 0xF4ABFF)

    // Semantic colors: Light / Dark
    static let background = dynamic(0xFAFAF7, 0x141416)
    static let surface = dynamic(0xFFFFFF, 0x242427)
    static let surfaceRaised = dynamic(0xF5F5F0, 0x303034)

    static let textPrimary = dynamic(0x151515, 0xFAFAF7)
    static let textSecondary = dynamic(0x48484B, 0xC6C6CA)

    static let border = dynamic(0xD5D5D0, 0x55555A)
    static let divider = dynamic(0xE5E5DF, 0x414146)

    static let primaryAction = lime
    static let primaryActionText = Color(hex: 0x151515)

    static let secondaryAction = dynamic(0xFFFFFF, 0x303034)
    static let secondaryActionText = dynamic(0x151515, 0xFAFAF7)

    static let success = dynamic(0x176C46, 0x79E3AE)
    static let error = dynamic(0xA12B35, 0xFF929C)

    private static func dynamic(
        _ light: UInt,
        _ dark: UInt
    ) -> Color {
        Color(uiColor: UIColor { traits in
            let hex = traits.userInterfaceStyle == .dark
                ? dark : light

            return UIColor(rgb: hex)
        })
    }
}


enum RestyleTypography {

    
    static let largeTitle = Font.system(
        .largeTitle, design: .default, weight: .bold
    )

    static let title2 = Font.system(
        .title2, design: .default, weight: .semibold
    )

    static let headline = Font.system(
        .headline, design: .default, weight: .semibold
    )

    static let body = Font.body
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote

    
    static func editorial(_ size: CGFloat = 36) -> Font {
        .custom(
            "BarlowCondensed-ExtraBoldItalic",
            size: size,
            relativeTo: .largeTitle
        )
    }
}



enum RestyleSpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let regular: CGFloat = 16
    static let large: CGFloat = 20
    static let xLarge: CGFloat = 24
    static let section: CGFloat = 32

    static let screenPadding: CGFloat = 20
    static let minimumTouchTarget: CGFloat = 44
}



enum RestyleRadius {
    static let small: CGFloat = 8
    static let control: CGFloat = 12
    static let card: CGFloat = 16
    static let featureCard: CGFloat = 24
}



extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

private extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
