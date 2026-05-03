import SwiftUI

struct StickerStar: View {
    var size: CGFloat = 32
    var fill: Color = DH.butter
    var stroke: Color = .white
    var strokeWidth: CGFloat = 2.5

    var body: some View {
        Star()
            .fill(fill)
            .overlay(Star().stroke(stroke, style: StrokeStyle(lineWidth: strokeWidth * size / 32, lineJoin: .round)))
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private struct Star: Shape {
        func path(in rect: CGRect) -> Path {
            let widthScale = rect.width / 32
            let heightScale = rect.height / 32

            func point(_ xCoordinate: CGFloat, _ yCoordinate: CGFloat) -> CGPoint {
                CGPoint(x: rect.minX + xCoordinate * widthScale, y: rect.minY + yCoordinate * heightScale)
            }

            var path = Path()
            path.move(to: point(16, 2))
            path.addLine(to: point(20, 11))
            path.addLine(to: point(30, 12))
            path.addLine(to: point(23, 19))
            path.addLine(to: point(25, 29))
            path.addLine(to: point(16, 24))
            path.addLine(to: point(7, 29))
            path.addLine(to: point(9, 19))
            path.addLine(to: point(2, 12))
            path.addLine(to: point(12, 11))
            path.closeSubpath()
            return path
        }
    }
}
