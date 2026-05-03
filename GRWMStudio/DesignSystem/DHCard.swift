import SwiftUI

struct DHCard<Content: View>: View {
    var bg: Color = .white
    var deep: Color = DH.pink
    var cornerRadius: CGFloat = DH.Radius.card
    var padding: CGFloat = 16

    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(deep)
                        .offset(y: 4)
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(bg)
                }
                .shadow(color: deep.opacity(0.35), radius: 14, x: 0, y: 7)
            }
    }
}

#Preview("DHCard") {
    VStack(spacing: 18) {
        DHCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dream Card")
                    .font(DH.font(.headline))
                    .tracking(DH.tracking(.headline))
                    .foregroundStyle(DH.pinkDeep)
                Text("A chunky toy-plastic surface.")
                    .font(DH.font(.body))
                    .foregroundStyle(DH.ink)
            }
        }

        DHCard(bg: DH.butter, deep: DH.butterDeep, cornerRadius: DH.Radius.bigCard, padding: 20) {
            Text("Butter Variant")
                .font(DH.font(.headline))
                .tracking(DH.tracking(.headline))
                .foregroundStyle(DH.ink)
        }
    }
    .padding(24)
    .background(DH.pinkPaper)
}
