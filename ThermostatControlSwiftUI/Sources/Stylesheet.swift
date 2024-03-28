import UIKit
import SwiftUI

public enum Stylesheet {

    // MARK: - Colors

    enum Color {
        static let coldMode = SwiftUI.Color(UIColor(hex: "#00E0FF") ?? .blue)
        static let hotMode = SwiftUI.Color(UIColor(hex: "#FFC700") ?? .orange)
        static let autoMode = SwiftUI.Color(UIColor(hex: "#30D158") ?? .green)
    }

    // MARK: - Fonts

    enum FontFace: String {
        case SFProRoundedRegular = "SFProRounded-Regular"
        case SFProRoundedBold = "SFProRounded-Bold"
        case SFProRoundedSemiBold = "SFProRounded-SemiBold"
        case SFProRoundedMedium = "SFProRounded-Medium"
    }
}

// MARK: - Helpers

extension Stylesheet.Color {

}

extension Stylesheet.FontFace {

    func font(_ size: CGFloat) -> Font {
        return Font.custom(self.rawValue, size: size)
    }

    static func printAvailableFonts() {
        for name in UIFont.familyNames {
            debugPrint("<<<<<<< Font Family: \(name)")
            for fontName in UIFont.fontNames(forFamilyName: name) {
                debugPrint("\(fontName)")
            }
        }
    }

}
