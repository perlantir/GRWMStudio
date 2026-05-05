import SwiftUI

struct PurchasesSection: View {
    @Environment(ProEntitlements.self) private var entitlements
    let onParentGatedIntent: (ParentGateIntent) -> Void

    var body: some View {
        SettingsGroup(title: L10n.string("settings.group.purchases")) {
            if entitlements.isPro {
                SettingsRow(
                    icon: "crown.fill",
                    iconBackground: DH.butter,
                    title: L10n.string("settings.account.studio_pro"),
                    subtitle: L10n.string("settings.account.pro_unlocked")
                )

                divider

                SettingsRow(
                    icon: "creditcard.fill",
                    iconBackground: DH.mint,
                    title: L10n.string("settings.purchases.manage"),
                    trailing: {
                        chevron
                    },
                    onTap: {
                        onParentGatedIntent(.manageSubscription)
                    }
                )

                divider

                SettingsRow(
                    icon: "arrow.uturn.backward.circle.fill",
                    iconBackground: DH.lavender,
                    title: L10n.string("settings.purchases.refund"),
                    trailing: {
                        chevron
                    },
                    onTap: {
                        onParentGatedIntent(.privacyDeepLink(PurchaseLinks.requestRefund))
                    }
                )
            } else {
                SettingsRow(
                    icon: "lock.fill",
                    iconBackground: DH.pink,
                    title: L10n.string("settings.account.studio_pro"),
                    subtitle: L10n.string("settings.account.pro_locked"),
                    trailing: {
                        chevron
                    },
                    onTap: {
                        onParentGatedIntent(.paywall(source: .settings))
                    }
                )
            }
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(DH.pinkDeep)
    }

    private var divider: some View {
        Divider()
            .overlay(DH.pinkPaper)
            .padding(.leading, 62)
    }
}
