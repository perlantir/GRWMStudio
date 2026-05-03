import SwiftUI

extension DH {
    struct ChunkyShadow {
        let solidColor: Color
        let solidOffset: CGFloat
        let blurColor: Color
        let blurRadius: CGFloat
        let blurY: CGFloat

        static func sm(deep: Color = DH.pinkDeep) -> Self {
            .init(solidColor: deep, solidOffset: 3, blurColor: deep.opacity(0.35), blurRadius: 10, blurY: 5)
        }

        static func md(deep: Color = DH.pinkDeep) -> Self {
            .init(solidColor: deep, solidOffset: 4, blurColor: deep.opacity(0.35), blurRadius: 14, blurY: 7)
        }

        static func lg(deep: Color = DH.pinkDeep) -> Self {
            .init(solidColor: deep, solidOffset: 6, blurColor: deep.opacity(0.40), blurRadius: 26, blurY: 12)
        }
    }

    @ViewBuilder
    static func chunkyShadowedRect(
        cornerRadius: CGFloat,
        size: ChunkyShadow,
        fillColor: Color,
        shadowColor: Color
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(shadowColor)
                .offset(y: size.solidOffset)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(fillColor)
        }
        .shadow(color: size.blurColor, radius: size.blurRadius, x: 0, y: size.blurY)
    }

    @ViewBuilder
    static func chunkyShadowedRect(
        cornerRadius: CGFloat,
        size: ChunkyShadow,
        fillColor: Color,
        deepColor: Color
    ) -> some View {
        chunkyShadowedRect(cornerRadius: cornerRadius, size: size, fillColor: fillColor, shadowColor: deepColor)
    }
}

extension View {
    func chunkyShadow(_ shadow: DH.ChunkyShadow) -> some View {
        chunkyShadow(shadow, shape: RoundedRectangle(cornerRadius: DH.Radius.card))
    }

    func chunkyShadow<S: Shape>(_ shadow: DH.ChunkyShadow, shape: S) -> some View {
        modifier(ChunkyShadowModifier(shadow: shadow, shape: shape))
    }
}

private struct ChunkyShadowModifier<S: Shape>: ViewModifier {
    let shadow: DH.ChunkyShadow
    let shape: S

    func body(content: Content) -> some View {
        ZStack {
            shape
                .fill(shadow.solidColor)
                .offset(y: shadow.solidOffset)
            content
        }
        .shadow(color: shadow.blurColor, radius: shadow.blurRadius, x: 0, y: shadow.blurY)
    }
}

#Preview("Chunky Shadows") {
    HStack(spacing: DH.Spacing.sectionGap) {
        DH.chunkyShadowedRect(cornerRadius: DH.Radius.card, size: .sm(), fillColor: DH.cream, shadowColor: DH.pinkDeep)
            .frame(width: 72, height: 52)
        DH.chunkyShadowedRect(cornerRadius: DH.Radius.card, size: .md(), fillColor: DH.pinkLight, shadowColor: DH.pinkDeep)
            .frame(width: 72, height: 52)
        DH.chunkyShadowedRect(cornerRadius: DH.Radius.card, size: .lg(), fillColor: DH.butter, shadowColor: DH.butterDeep)
            .frame(width: 72, height: 52)
    }
    .padding(32)
    .background(DH.pinkPaper)
}

#Preview("Generic Image Shadow") {
    Image(systemName: "sparkles")
        .font(.system(size: 44, weight: .bold))
        .foregroundStyle(DH.pink)
        .frame(width: 96, height: 96)
        .background(
            RoundedRectangle(cornerRadius: DH.Radius.card)
                .fill(DH.cream)
        )
        .chunkyShadow(.md(), shape: RoundedRectangle(cornerRadius: DH.Radius.card))
        .padding(32)
        .background(DH.pinkPaper)
}
