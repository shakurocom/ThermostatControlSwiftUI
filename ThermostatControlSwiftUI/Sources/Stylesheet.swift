import UIKit
import SwiftUI

public enum Stylesheet {

    // MARK: - Fonts

    enum FontFace: String {
        case SFProRoundedRegular = "SFProRounded-Regular"
        case SFProRoundedBold = "SFProRounded-Bold"
        case SFProRoundedSemiBold = "SFProRounded-SemiBold"
        case SFProRoundedMedium = "SFProRounded-Medium"
    }
}

// MARK: - Helpers

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
