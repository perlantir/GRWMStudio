import SwiftUI

struct PermRow: View {
    let title: String
    let description: String
    let iconSystemName: String
    let iconBackground: Color
    let iconDeep: Color
    let iconForeground: Color
    let status: AppPermissionStatus
    let isRequesting: Bool
    let onAllow: () -> Void

    init(
        title: String,
        description: String,
        iconSystemName: String,
        iconBackground: Color,
        iconDeep: Color,
        iconForeground: Color = .white,
        status: AppPermissionStatus,
        isRequesting: Bool,
        onAllow: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.iconSystemName = iconSystemName
        self.iconBackground = iconBackground
        self.iconDeep = iconDeep
        self.iconForeground = iconForeground
        self.status = status
        self.isRequesting = isRequesting
        self.onAllow = onAllow
    }

    var body: some View {
        DHCard(bg: .white, deep: DH.pinkLight, cornerRadius: 20, padding: 12) {
            HStack(spacing: 12) {
                icon

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(DH.font(.bodyEmphasis))
                        .foregroundStyle(DH.ink)

                    Text(description)
                        .font(DH.font(.caption))
                        .foregroundStyle(DH.ink.opacity(0.55))
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                statusBadge
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.format("onboarding.permissions.row.accessibility_label", title, description, accessibilityStatus))
    }

    private var icon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(iconBackground)
                .frame(width: 48, height: 48)
                .shadow(color: iconDeep, radius: 0, x: 0, y: 3)

            Image(systemName: iconSystemName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(iconForeground)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var statusBadge: some View {
        if isRequesting {
            badge(title: L10n.string("onboarding.permissions.status.asking"), foreground: DH.ink, background: DH.butter)
        } else {
            switch status {
            case .notDetermined:
                DHButton(title: L10n.string("common.allow"), kind: .primary, size: .sm, action: onAllow)
                    .accessibilityLabel(L10n.format("onboarding.permissions.allow_accessibility_label", title))
            case .granted:
                badge(title: L10n.string("onboarding.permissions.status.granted"), foreground: DH.pinkDeep, background: DH.mint)
            case .denied:
                badge(title: L10n.string("onboarding.permissions.status.denied"), foreground: .white, background: DH.recRed)
            case .restricted:
                badge(title: L10n.string("onboarding.permissions.status.restricted"), foreground: .white, background: DH.recRed)
            }
        }
    }

    private func badge(title: String, foreground: Color, background: Color) -> some View {
        Text(title)
            .font(DH.font(.caption))
            .tracking(0.08 * DH.TypeStyle.caption.size)
            .foregroundStyle(foreground)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .frame(height: 32)
            .background(Capsule().fill(background))
    }

    private var accessibilityStatus: String {
        if isRequesting {
            return L10n.string("onboarding.permissions.status.asking_plain")
        }

        switch status {
        case .notDetermined:
            return L10n.string("onboarding.permissions.status.not_determined")
        case .granted:
            return L10n.string("onboarding.permissions.status.granted_plain")
        case .denied:
            return L10n.string("onboarding.permissions.status.denied_plain")
        case .restricted:
            return L10n.string("onboarding.permissions.status.restricted_plain")
        }
    }
}

#Preview("Permission Row") {
    VStack(spacing: 10) {
        PermRow(
            title: "Camera",
            description: "See yourself in the magic mirror",
            iconSystemName: "camera.fill",
            iconBackground: DH.pink,
            iconDeep: DH.pinkDeep,
            status: .notDetermined,
            isRequesting: false
        ) {}
        PermRow(
            title: "Microphone",
            description: "Record sound only when you make a video",
            iconSystemName: "mic.fill",
            iconBackground: DH.butter,
            iconDeep: DH.butterDeep,
            iconForeground: DH.ink,
            status: .granted,
            isRequesting: false
        ) {}
    }
    .padding(24)
    .background(DH.cream)
}
