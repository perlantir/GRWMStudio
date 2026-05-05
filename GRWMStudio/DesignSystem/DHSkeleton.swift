import SwiftUI

struct AnyShape: Shape {
    private let pathBuilder: @Sendable (CGRect) -> Path

    init<S: Shape & Sendable>(_ shape: S) {
        pathBuilder = { rect in
            shape.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

struct DHSkeleton: View {
    let shape: AnyShape
    @State private var phase: CGFloat = -1

    var body: some View {
        shape
            .fill(
                LinearGradient(
                    colors: [DH.pinkPaper, DH.cream, DH.pinkPaper],
                    startPoint: UnitPoint(x: phase, y: 0.5),
                    endPoint: UnitPoint(x: phase + 0.6, y: 0.5)
                )
            )
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .accessibilityHidden(true)
    }
}

struct DHSpinner: View {
    var size: CGFloat = 48
    var lineWidth: CGFloat = 6

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(DH.pinkPaper, lineWidth: lineWidth)
                .frame(width: size, height: size)

            Circle()
                .trim(from: 0.1, to: 0.7)
                .stroke(
                    DH.pink,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(rotation))

            Text("✨")
                .font(.system(size: size * 0.38))
        }
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        .accessibilityLabel(Text(L10n.string("common.loading")))
    }
}
