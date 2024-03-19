import UIKit
import SwiftUI

public enum Stylesheet {

    // MARK: - Colors

    enum Color {
        static let coldMode = UIColor(hex: "#00E0FF")
        static let hotMode = UIColor(hex: "#FFC700")
        static let autoMode = UIColor(hex: "#30D158")
    }

    // MARK: - Fonts

    enum FontFace: String {
        case SFProRoundedRegular = "SFProRounded-Regular"
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
