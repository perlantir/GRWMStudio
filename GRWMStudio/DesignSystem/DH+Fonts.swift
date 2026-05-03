import CoreText
import SwiftUI

extension DH {
    enum TypeStyle: String, CaseIterable {
        case display1
        case display2
        case display3
        case headline
        case body
        case bodyEmphasis
        case caption
        case microLabel
        case buttonSmall
        case buttonLarge
    }

    static func font(_ style: TypeStyle) -> Font {
        switch style {
        case .display1:
            .custom("Fredoka-Bold", size: 96)
        case .display2:
            .custom("Fredoka-Bold", size: 48)
        case .display3:
            .custom("Fredoka-Bold", size: 32)
        case .headline:
            .custom("Fredoka-Bold", size: 22)
        case .body:
            .custom("Quicksand-Medium", size: 14)
        case .bodyEmphasis:
            .custom("Quicksand-Bold", size: 14)
        case .caption:
            .custom("Fredoka-SemiBold", size: 11)
        case .microLabel:
            .custom("Fredoka-SemiBold", size: 9)
        case .buttonSmall:
            .custom("Fredoka-Bold", size: 12)
        case .buttonLarge:
            .custom("Fredoka-Bold", size: 18)
        }
    }

    static func tracking(_ style: TypeStyle) -> CGFloat {
        switch style {
        case .display1, .display2, .display3:
            -0.02 * style.size
        case .headline:
            -0.01 * style.size
        case .body, .buttonSmall, .buttonLarge:
            0
        case .bodyEmphasis:
            0.02 * style.size
        case .caption:
            0.16 * style.size
        case .microLabel:
            0.32 * style.size
        }
    }
}

extension DH.TypeStyle {
    var size: CGFloat {
        switch self {
        case .display1:
            96
        case .display2:
            48
        case .display3:
            32
        case .headline:
            22
        case .body, .bodyEmphasis:
            14
        case .caption:
            11
        case .microLabel:
            9
        case .buttonSmall:
            12
        case .buttonLarge:
            18
        }
    }
}

#Preview("DH Type Scale") {
    ScrollView {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(DH.TypeStyle.allCases, id: \.self) { style in
                VStack(alignment: .leading, spacing: 4) {
                    Text(style.rawValue)
                        .font(DH.font(.microLabel))
                        .tracking(DH.tracking(.microLabel))
                        .foregroundStyle(DH.pinkDeep)
                    Text(sampleText(for: style))
                        .font(DH.font(style))
                        .tracking(DH.tracking(style))
                        .foregroundStyle(DH.ink)
                }
            }
        }
        .padding(28)
    }
    .background(DH.pinkPaper)
}

private func sampleText(for style: DH.TypeStyle) -> String {
    switch style {
    case .display1:
        "GRWM"
    case .display2:
        "Dream Look"
    case .display3:
        "Mirror Magic"
    case .headline:
        "Choose Your Sparkle"
    case .body:
        "Soft rounded body copy for the studio."
    case .bodyEmphasis:
        "Bold Quicksand body emphasis."
    case .caption:
        "CAPTION LABEL"
    case .microLabel:
        "MICRO LABEL"
    case .buttonSmall:
        "SMALL BUTTON"
    case .buttonLarge:
        "BIG BUTTON"
    }
}
