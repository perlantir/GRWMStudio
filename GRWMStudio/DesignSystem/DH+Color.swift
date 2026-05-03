import SwiftUI
import UIKit

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let components = DHColorComponents(hex: hex, alpha: alpha)
        self.init(.sRGB, red: components.red, green: components.green, blue: components.blue, opacity: components.alpha)
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let components = DHColorComponents(hex: hex, alpha: Double(alpha))
        self.init(
            red: CGFloat(components.red),
            green: CGFloat(components.green),
            blue: CGFloat(components.blue),
            alpha: CGFloat(components.alpha)
        )
    }
}

private struct DHColorComponents {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(hex: UInt32, alpha: Double) {
        if hex > 0xFFFFFF {
            red = Double((hex & 0xFF000000) >> 24) / 255
            green = Double((hex & 0x00FF0000) >> 16) / 255
            blue = Double((hex & 0x0000FF00) >> 8) / 255
            self.alpha = (Double(hex & 0x000000FF) / 255) * alpha
        } else {
            red = Double((hex & 0xFF0000) >> 16) / 255
            green = Double((hex & 0x00FF00) >> 8) / 255
            blue = Double(hex & 0x0000FF) / 255
            self.alpha = alpha
        }
    }
}
