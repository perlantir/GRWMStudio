import SwiftUI

struct LockerProfileHeroView: View {
    let viewModel: LockerViewModel
    let onEditAvatar: () -> Void
    let onShowSettings: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: onShowSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.26), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(L10n.string("settings.title"))
                .accessibilityHint(L10n.string("locker.profile.settings_hint"))

                Spacer()
            }

            Button(action: onEditAvatar) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(viewModel.avatarSwatch.fill)
                        .frame(width: 118, height: 118)
                        .overlay(Circle().stroke(.white, lineWidth: 5))
                        .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 6)
                        .shadow(color: DH.pinkDeep.opacity(0.35), radius: 18, x: 0, y: 10)
                        .overlay {
                            Image(systemName: "face.smiling.inverse")
                                .font(.system(size: 50, weight: .black))
                                .foregroundStyle(viewModel.avatarSwatch.accent)
                        }

                    Circle()
                        .fill(DH.mint)
                        .frame(width: 22, height: 22)
                        .overlay(Circle().stroke(.white, lineWidth: 3))
                        .padding(8)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("profile.edit_avatar"))
            .accessibilityHint(L10n.string("locker.profile.edit_avatar_hint"))

            DHButton(title: L10n.string("profile.edit_avatar"), kind: .butter, size: .sm, action: onEditAvatar)
                .accessibilityLabel(L10n.string("profile.edit_avatar"))

            VStack(spacing: 4) {
                Text(viewModel.displayName)
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(.white)
                    .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 3)

                Text(viewModel.tagline)
                    .font(DH.font(.body))
                    .tracking(DH.tracking(.body))
                    .foregroundStyle(.white.opacity(0.88))
            }
            .multilineTextAlignment(.center)

            HStack(spacing: 8) {
                LockerProfileStatCard(value: "\(viewModel.captures.count)", label: L10n.string("locker.profile.looks_saved"))
                LockerProfileStatCard(value: "\(viewModel.looksTriedCount)", label: L10n.string("locker.profile.looks_tried"))
                LockerProfileStatCard(value: "\(viewModel.streakDays)", label: L10n.string("locker.profile.streak"))
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(verbatim: viewModel.glowLevelLabel)
                        .font(DH.font(.headline))
                        .tracking(DH.tracking(.headline))
                        .foregroundStyle(DH.ink)

                    Spacer()

                    Text(viewModel.glowProgressLabel)
                        .font(DH.font(.caption))
                        .tracking(DH.tracking(.caption))
                        .foregroundStyle(DH.ink.opacity(0.55))
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white)
                            .shadow(color: DH.pinkDeep.opacity(0.12), radius: 0, x: 0, y: 2)

                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: [DH.pinkLight, DH.pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(16, proxy.size.width * viewModel.glowPercent))

                        StickerSparkle(size: 14, fill: .white)
                            .position(
                                x: min(max(14, proxy.size.width * viewModel.glowPercent), max(14, proxy.size.width - 14)),
                                y: 9
                            )
                    }
                }
                .frame(height: 18)
            }
            .padding(14)
            .background(.white, in: RoundedRectangle(cornerRadius: 20))
            .chunkyShadow(.sm(deep: DH.pinkLight), shape: RoundedRectangle(cornerRadius: 20))
        }
    }
}

private struct LockerProfileStatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(DH.font(.buttonLarge))
                .tracking(DH.tracking(.buttonLarge))
                .foregroundStyle(DH.pinkDeep)

            Text(label)
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.ink.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .chunkyShadow(.sm(deep: DH.pinkLight), shape: RoundedRectangle(cornerRadius: 18))
    }
}
