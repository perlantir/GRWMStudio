import SwiftUI

struct LookTutorialOverlay: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.48)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack {
                Spacer()

                VStack(spacing: 6) {
                    DHCard(bg: DH.butter, deep: DH.pinkDeep, cornerRadius: 20, padding: 14) {
                        HStack(spacing: 10) {
                            StickerSparkle(size: 20, fill: DH.pinkDeep)
                            Text("looks.tutorial.title")
                                .font(DH.font(.headline))
                                .tracking(DH.tracking(.headline))
                                .foregroundStyle(DH.ink)
                        }
                    }

                    Triangle()
                        .fill(DH.butter)
                        .frame(width: 22, height: 14)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 106)
            }
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
