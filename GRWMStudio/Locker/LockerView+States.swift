import SwiftUI

extension LockerView {
    var deleteModeBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "trash.fill")
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(DH.recRedDeep))

            VStack(alignment: .leading, spacing: 2) {
                Text("locker.delete_mode.title")
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)

                Text("locker.delete_mode.subtitle")
                    .font(DH.font(.caption))
                    .tracking(DH.tracking(.caption))
                    .foregroundStyle(DH.ink.opacity(0.72))
            }

            Spacer(minLength: 0)

            DHButton(title: L10n.string("common.done"), kind: .ghost, size: .sm) {
                deleteMode = false
            }
            .frame(width: 96)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: DH.Radius.card)
                .fill(.white.opacity(0.92))
                .chunkyShadow(.sm(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.card))
        )
        .accessibilityIdentifier("locker-delete-mode-banner")
    }

    var lockerLoadingState: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 24)))
                    .frame(height: 164)

                DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 18)))
                    .frame(width: 148, height: 28)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    VStack(spacing: 8) {
                        DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 20)))
                            .frame(height: 118)
                        DHSkeleton(shape: AnyShape(RoundedRectangle(cornerRadius: 12)))
                            .frame(height: 16)
                    }
                }
            }
        }
    }
}
