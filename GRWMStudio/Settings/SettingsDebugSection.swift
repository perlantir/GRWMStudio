import SwiftUI

#if DEBUG
struct SettingsDebugSection: View {
    let onShowErrorTrigger: () -> Void
    let onReset: () -> Void

    var body: some View {
        SettingsGroup(title: L10n.string("settings.group.developer")) {
            SettingsRow(
                icon: "ladybug.fill",
                iconBackground: DH.mint,
                title: L10n.string("settings.developer.error_trigger"),
                subtitle: L10n.string("settings.developer.error_trigger_subtitle"),
                trailing: { SettingsChevron() },
                onTap: onShowErrorTrigger
            )

            SettingsDivider()

            SettingsRow(
                icon: "arrow.counterclockwise",
                iconBackground: DH.ink.opacity(0.18),
                title: L10n.string("settings.developer.reset_onboarding"),
                subtitle: L10n.string("settings.developer.reset_onboarding_subtitle"),
                trailing: { SettingsChevron() },
                onTap: onReset
            )
        }
    }
}
#endif
