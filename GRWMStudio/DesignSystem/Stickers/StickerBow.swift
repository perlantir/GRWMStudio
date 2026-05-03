import SwiftUI

struct StickerBow: View {
    var size: CGFloat = 32
    var fill: Color = DH.pinkLight
    var stroke: Color = .white
    var strokeWidth: CGFloat = 2

    var body: some View {
        Bow()
            .fill(fill)
            .overlay(Bow().stroke(stroke, style: StrokeStyle(lineWidth: strokeWidth * size / 36, lineJoin: .round)))
            .aspectRatio(1.5, contentMode: .fit)
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }

    private struct Bow: Shape {
        func path(in rect: CGRect) -> Path {
            let scale = min(rect.width / 36, rect.height / 24)
            let xOffset = rect.minX + (rect.width - 36 * scale) / 2
            let yOffset = rect.minY + (rect.height - 24 * scale) / 2

            func point(_ xCoordinate: CGFloat, _ yCoordinate: CGFloat) -> CGPoint {
                CGPoint(x: xOffset + xCoordinate * scale, y: yOffset + yCoordinate * scale)
            }

            func ellipse(centerX: CGFloat, centerY: CGFloat, radiusX: CGFloat, radiusY: CGFloat) -> CGRect {
                CGRect(
                    x: xOffset + (centerX - radiusX) * scale,
                    y: yOffset + (centerY - radiusY) * scale,
                    width: radiusX * 2 * scale,
                    height: radiusY * 2 * scale
                )
            }

            var path = Path()
            path.move(to: point(18, 12))
            path.addLine(to: point(4, 4))
            path.addLine(to: point(4, 20))
            path.closeSubpath()
            path.move(to: point(18, 12))
            path.addLine(to: point(32, 4))
            path.addLine(to: point(32, 20))
            path.closeSubpath()
            path.addEllipse(in: ellipse(centerX: 18, centerY: 12, radiusX: 3.5, radiusY: 4.5))
            return path
        }
    }
}
