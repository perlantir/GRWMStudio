import SwiftUI

struct MathChip: View {
    let value: String
    let hollow: Bool

    var body: some View {
        Text(value)
            .font(DH.font(.headline))
            .tracking(DH.tracking(.headline))
            .foregroundStyle(DH.pinkDeep)
            .frame(width: 60, height: 60)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(hollow ? .clear : DH.pinkLight)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        DH.pinkDeep,
                        style: StrokeStyle(lineWidth: 3, dash: hollow ? [6, 5] : [])
                    )
            }
            .overlay {
                if !hollow {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white, lineWidth: 3)
                }
            }
            .shadow(color: hollow ? .clear : DH.pink.opacity(0.45), radius: 0, x: 0, y: 4)
    }
}
