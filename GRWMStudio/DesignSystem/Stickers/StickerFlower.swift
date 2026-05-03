import SwiftUI

struct StickerFlower: View {
    var size: CGFloat = 32
    var petal: Color = DH.pink
    var center: Color = DH.butter
    var stroke: Color = .white
    var strokeWidth: CGFloat = 2

    var body: some View {
        ZStack {
            petalCircle(centerX: 16, centerY: 6, radius: 5)
            petalCircle(centerX: 6, centerY: 16, radius: 5)
            petalCircle(centerX: 26, centerY: 16, radius: 5)
            petalCircle(centerX: 16, centerY: 26, radius: 5)
            petalCircle(centerX: 9, centerY: 9, radius: 4.5)
            petalCircle(centerX: 23, centerY: 9, radius: 4.5)
            petalCircle(centerX: 9, centerY: 23, radius: 4.5)
            petalCircle(centerX: 23, centerY: 23, radius: 4.5)
            circle(centerX: 16, centerY: 16, radius: 5, fill: center)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private func petalCircle(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) -> some View {
        circle(centerX: centerX, centerY: centerY, radius: radius, fill: petal)
    }

    private func circle(centerX: CGFloat, centerY: CGFloat, radius: CGFloat, fill: Color) -> some View {
        Circle()
            .fill(fill)
            .overlay(Circle().stroke(stroke, lineWidth: strokeWidth * size / 32))
            .frame(width: radius * 2 * size / 32, height: radius * 2 * size / 32)
            .position(x: centerX * size / 32, y: centerY * size / 32)
    }
}
