import SwiftUI

struct LockerAtLimitBanner: View {
    var body: some View {
        DHCard(bg: DH.butter, deep: DH.butterDeep, cornerRadius: 20, padding: 14) {
            HStack(spacing: 10) {
                Text("💼")
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 2) {
                    Text("locker.limit.title")
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(DH.ink)

                    Text("locker.limit.subtitle")
                        .font(DH.font(.body))
                        .tracking(DH.tracking(.body))
                        .foregroundStyle(DH.ink.opacity(0.72))
                }

                Spacer(minLength: 0)
            }
        }
    }
}
