import SwiftUI

struct StickerSparkle: View {
    var size: CGFloat = 24
    var fill: Color = .white
    var stroke: Color?
    var strokeWidth: CGFloat = 1.5

    var body: some View {
        Sparkle()
            .fill(fill)
            .overlay {
                if let stroke {
                    Sparkle().stroke(stroke, style: StrokeStyle(lineWidth: strokeWidth * size / 24, lineJoin: .round))
                }
            }
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private struct Sparkle: Shape {
        func path(in rect: CGRect) -> Path {
            let widthScale = rect.width / 24
            let heightScale = rect.height / 24

            func point(_ xCoordinate: CGFloat, _ yCoordinate: CGFloat) -> CGPoint {
                CGPoint(x: rect.minX + xCoordinate * widthScale, y: rect.minY + yCoordinate * heightScale)
            }

            var path = Path()
            path.move(to: point(12, 2))
            path.addLine(to: point(14, 9))
            path.addLine(to: point(21, 11))
            path.addLine(to: point(14, 13))
            path.addLine(to: point(12, 20))
            path.addLine(to: point(10, 13))
            path.addLine(to: point(3, 11))
            path.addLine(to: point(10, 9))
            path.closeSubpath()
            return path
        }
    }
}
