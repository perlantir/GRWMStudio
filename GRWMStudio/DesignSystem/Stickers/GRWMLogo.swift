import SwiftUI

struct GRWMLogo: View {
    enum Layout {
        case stack
        case row
    }

    enum Size {
        case sm
        case md
        case lg
        case xl

        var scale: CGFloat {
            switch self {
            case .sm:
                0.24
            case .md:
                0.32
            case .lg:
                0.62
            case .xl:
                1.0
            }
        }
    }

    var layout: Layout = .stack
    var size: Size = .lg

    var body: some View {
        switch layout {
        case .stack:
            VStack(spacing: 10 * scale) {
                grwmText
                studioSubtitle
            }
        case .row:
            HStack(spacing: 8 * scale) {
                rowTitle
                StickerHeart(size: heartSize * 0.42, fill: DH.pinkDeep, strokeWidth: 3)
                studioSubtitle
            }
            .fixedSize(horizontal: true, vertical: true)
            .alignmentGuide(.firstTextBaseline) { dimensions in
                dimensions[.bottom]
            }
        }
    }

    private var scale: CGFloat {
        size.scale
    }

    private var heartSize: CGFloat {
        34 * scale
    }

    private var grwmFontSize: CGFloat {
        96 * scale
    }

    private var studioFontSize: CGFloat {
        switch layout {
        case .stack:
            32 * scale
        case .row:
            18 * scale * 0.7
        }
    }

    private var grwmFont: Font {
        .custom("Fredoka-Bold", size: grwmFontSize)
    }

    private var rowFont: Font {
        .custom("Fredoka-Bold", size: grwmFontSize * 0.38)
    }

    private var studioFont: Font {
        .custom("Fredoka-Bold", size: studioFontSize)
    }

    private var grwmText: some View {
        ZStack(alignment: .topTrailing) {
            strokeText("GRWM", font: grwmFont, offset: 4 * scale)
                .tracking(-0.02 * grwmFontSize)
                .foregroundStyle(.white)

            Text("GRWM")
                .font(grwmFont)
                .tracking(-0.02 * grwmFontSize)
                .foregroundStyle(DH.pink)

            StickerHeart(size: heartSize, fill: DH.pinkDeep, strokeWidth: 3)
                .offset(x: 38 * scale, y: -16 * scale)
        }
        .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 7 * scale)
        .shadow(color: DH.pinkDeep.opacity(0.4), radius: 22 * scale, x: 0, y: 12 * scale)
    }

    private var rowTitle: some View {
        ZStack {
            strokeText("GRWM", font: rowFont, offset: 1.6 * scale)
                .tracking(-0.02 * grwmFontSize * 0.38)
                .foregroundStyle(.white)

            Text("GRWM")
                .font(rowFont)
                .tracking(-0.02 * grwmFontSize * 0.38)
                .foregroundStyle(DH.pink)
        }
        .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 3 * scale)
    }

    private var studioSubtitle: some View {
        Text("STUDIO")
            .font(studioFont)
            .tracking((layout == .stack ? 0.32 : 0.28) * studioFontSize)
            .foregroundStyle(DH.pinkDeep)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.leading, (layout == .stack ? 0.32 : 0.28) * studioFontSize)
    }

    private func strokeText(_ text: String, font: Font, offset: CGFloat) -> some View {
        ZStack {
            Text(text).font(font).offset(x: -offset, y: -offset)
            Text(text).font(font).offset(x: 0, y: -offset)
            Text(text).font(font).offset(x: offset, y: -offset)
            Text(text).font(font).offset(x: -offset, y: 0)
            Text(text).font(font).offset(x: offset, y: 0)
            Text(text).font(font).offset(x: -offset, y: offset)
            Text(text).font(font).offset(x: 0, y: offset)
            Text(text).font(font).offset(x: offset, y: offset)
        }
    }
}

extension View {
    func stickerBob(amplitude: CGFloat = 6, period: Double = 2.0) -> some View {
        modifier(StickerBobModifier(amplitude: amplitude, period: period))
    }
}

private struct StickerBobModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animating = false

    let amplitude: CGFloat
    let period: Double

    func body(content: Content) -> some View {
        content
            .offset(y: animating && !reduceMotion ? -amplitude : 0)
            .onAppear {
                guard !reduceMotion else {
                    return
                }

                withAnimation(.easeInOut(duration: period).repeatForever(autoreverses: true)) {
                    animating = true
                }
            }
            .onChange(of: reduceMotion) { _, reduceMotion in
                if reduceMotion {
                    animating = false
                }
            }
    }
}

#Preview("Stickers and Logo") {
    VStack(spacing: 28) {
        HStack(spacing: 18) {
            StickerHeart(size: 42)
            StickerStar(size: 42)
            StickerSparkle(size: 38, fill: .white)
            StickerFlower(size: 42)
            StickerBow(size: 42)
        }

        GRWMLogo(layout: .stack, size: .xl)
        GRWMLogo(layout: .row, size: .md)
    }
    .padding(40)
    .background(DH.pinkPaper)
}
