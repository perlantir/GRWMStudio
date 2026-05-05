import SwiftUI

struct FaceTrackingDots: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var color: Color = .white.opacity(0.55)

    @State private var pulse = false

    private let points: [CGPoint] = [
        CGPoint(x: 0.18, y: 0.28),
        CGPoint(x: 0.27, y: 0.22),
        CGPoint(x: 0.38, y: 0.18),
        CGPoint(x: 0.50, y: 0.16),
        CGPoint(x: 0.62, y: 0.18),
        CGPoint(x: 0.73, y: 0.22),
        CGPoint(x: 0.82, y: 0.28),
        CGPoint(x: 0.24, y: 0.40),
        CGPoint(x: 0.36, y: 0.36),
        CGPoint(x: 0.50, y: 0.34),
        CGPoint(x: 0.64, y: 0.36),
        CGPoint(x: 0.76, y: 0.40),
        CGPoint(x: 0.31, y: 0.56),
        CGPoint(x: 0.42, y: 0.60),
        CGPoint(x: 0.50, y: 0.62),
        CGPoint(x: 0.58, y: 0.60),
        CGPoint(x: 0.69, y: 0.56)
    ]

    var body: some View {
        GeometryReader { proxy in
            ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)
                    .scaleEffect(scale(for: index))
                    .position(x: proxy.size.width * point.x, y: proxy.size.height * point.y)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear {
            guard !reduceMotion else {
                return
            }

            withAnimation(DHAnim.respecting(.softSpring, reduceMotion: reduceMotion).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func scale(for index: Int) -> CGFloat {
        guard pulse, !reduceMotion else {
            return 1
        }

        return index.isMultiple(of: 2) ? 1.18 : 0.92
    }
}

#Preview("Face Tracking Dots") {
    ZStack {
        Color.black
        FaceTrackingDots()
            .padding(40)
    }
    .frame(width: 260, height: 340)
}
