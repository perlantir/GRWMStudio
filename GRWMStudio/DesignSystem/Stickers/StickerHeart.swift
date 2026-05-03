import SwiftUI

struct StickerHeart: View {
    var size: CGFloat = 32
    var fill: Color = DH.pink
    var stroke: Color = .white
    var strokeWidth: CGFloat = 2.5

    var body: some View {
        Heart()
            .fill(fill)
            .overlay(Heart().stroke(stroke, lineWidth: strokeWidth * size / 32))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private struct Heart: Shape {
        func path(in rect: CGRect) -> Path {
            let widthScale = rect.width / 32
            let heightScale = rect.height / 32

            func point(_ xCoordinate: CGFloat, _ yCoordinate: CGFloat) -> CGPoint {
                CGPoint(x: rect.minX + xCoordinate * widthScale, y: rect.minY + yCoordinate * heightScale)
            }

            var path = Path()
            path.move(to: point(16, 28))
            path.addCurve(to: point(2, 11), control1: point(16, 28), control2: point(2, 19))
            path.addCurve(to: point(13, 8), control1: point(1.8, 7.3), control2: point(8.6, 4.7))
            path.addCurve(to: point(24, 11), control1: point(17.4, 4.7), control2: point(24.2, 7.3))
            path.addCurve(to: point(16, 28), control1: point(24, 19), control2: point(16, 28))
            path.closeSubpath()
            return path
        }
    }
}
