import SwiftUI

struct DHWallpaperStripes: View {
    var primary: Color = DH.pinkPaper
    var secondary: Color = DH.cream
    var stripeWidth: CGFloat = 24
    var secondaryStripeWidth: CGFloat?
    var opacity: Double = 0.7

    var body: some View {
        Canvas { context, size in
            let bounds = CGRect(origin: .zero, size: size)
            let diagonal = sqrt(size.width * size.width + size.height * size.height)
            let secondaryWidth = secondaryStripeWidth ?? stripeWidth
            let period = stripeWidth + secondaryWidth

            context.fill(Path(bounds), with: .color(primary))
            context.translateBy(x: size.width / 2, y: size.height / 2)
            context.rotate(by: .degrees(45))

            var stripeX = -diagonal
            while stripeX < diagonal {
                let band = CGRect(
                    x: stripeX + stripeWidth,
                    y: -diagonal,
                    width: secondaryWidth,
                    height: diagonal * 2
                )
                context.fill(Path(band), with: .color(secondary))
                stripeX += period
            }
        }
        .opacity(opacity)
        .ignoresSafeArea()
    }
}

struct DHWallpaperGradient: View {
    var top: Color = DH.pinkPaper
    var bottom: Color = DH.cream
    var opacity: Double = 1.0

    var body: some View {
        LinearGradient(
            gradient: Gradient(stops: [
                .init(color: top, location: 0),
                .init(color: bottom, location: 0.6),
                .init(color: bottom, location: 1.0)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .opacity(opacity)
        .ignoresSafeArea()
    }
}

struct DHWallpaperRadial: View {
    var inner: Color = Color(hex: 0xFFE0EE)
    var outer: Color = Color(hex: 0xFFB3D9)
    var endRadius: CGFloat = 240
    var opacity: Double = 1.0

    var body: some View {
        RadialGradient(
            gradient: Gradient(colors: [inner, outer]),
            center: .center,
            startRadius: 0,
            endRadius: endRadius
        )
        .opacity(opacity)
    }
}

#Preview("DHWallpaper") {
    HStack(spacing: 14) {
        wallpaperPreview(title: "STRIPES") {
            DHWallpaperStripes()
        }
        wallpaperPreview(title: "GRADIENT") {
            DHWallpaperGradient()
        }
        wallpaperPreview(title: "RADIAL") {
            DHWallpaperRadial()
        }
    }
    .padding(24)
    .background(DH.pinkPaper)
}

private func wallpaperPreview<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(spacing: 8) {
        content()
            .frame(width: 104, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: DH.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: DH.Radius.card)
                    .stroke(.white, lineWidth: 3)
            }

        Text(title)
            .font(DH.font(.microLabel))
            .tracking(DH.tracking(.microLabel))
            .foregroundStyle(DH.pinkDeep)
    }
}
