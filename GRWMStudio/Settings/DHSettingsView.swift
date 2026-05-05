import SwiftData
import SwiftUI

struct DHSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var env
    @Environment(\.modelContext) private var modelContext
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(ProEntitlements.self) private var entitlements

    @State private var viewModel: SettingsViewModel?
    @State private var showAvatarEditor = false
    @State private var showDeleteConfirm = false
    @State private var presentedParentGate: ParentGateIntent?
    #if DEBUG
    @State private var showErrorTrigger = false
    #endif

    var body: some View {
        @Bindable var coordinator = coordinator

        ZStack(alignment: .top) {
            LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if let viewModel {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        SettingsHeaderView(onDismiss: { dismiss() })
                            .padding(.top, 58)

                        SettingsAccountSection(
                            viewModel: viewModel,
                            isPro: entitlements.isPro,
                            onEditAvatar: { showAvatarEditor = true },
                            onUnlockPro: {
                                presentedParentGate = .paywall(source: .settings)
                            }
                        )

                        SettingsPrivacySection(
                            viewModel: viewModel,
                            onOpenSettings: openSystemSettings
                        )

                        SettingsLookAndFeelSection(viewModel: viewModel)
                        PurchasesSection { intent in
                            presentedParentGate = intent
                        }

                        SettingsAboutSection(
                            viewModel: viewModel,
                            onOpenLink: openParentGatedLink
                        )

                        SettingsDangerZoneSection {
                            presentedParentGate = .deleteAllData
                        }

                        #if DEBUG
                        SettingsDebugSection(
                            onShowErrorTrigger: {
                                showErrorTrigger = true
                            },
                            onReset: {
                                env.onboarding.reset()
                                coordinator.route = .onboardingSplash
                                dismiss()
                            }
                        )
                        #endif
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 36)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(modelContext: modelContext)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deleteAllRequested)) { _ in
            showDeleteConfirm = true
        }
        .settingsCommercePresentation(
            parentGate: $presentedParentGate,
            coordinator: coordinator
        )
        .sheet(
            isPresented: $showAvatarEditor,
            onDismiss: {
                viewModel?.refreshProfile()
            },
            content: {
                if let record = viewModel?.profile {
                    AvatarEditorView(record: record) {
                        viewModel?.refreshProfile()
                    }
                }
            }
        )
        #if DEBUG
        .sheet(isPresented: $showErrorTrigger) {
            NavigationStack {
                ErrorTriggerView()
            }
        }
        #endif
        .alert(L10n.string("settings.delete_all.title"), isPresented: $showDeleteConfirm) {
            Button(L10n.string("common.delete"), role: .destructive) {
                Task { @MainActor in
                    await viewModel?.deleteAllLooks()
                    coordinator.showToast(L10n.string("settings.delete_all.toast"))
                }
            }
            Button(L10n.string("common.cancel"), role: .cancel) {}
        } message: {
            Text("settings.delete_all.message")
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            coordinator.showToast(L10n.string("settings.open_settings_error"))
            return
        }

        UIApplication.shared.open(url, options: [:]) { opened in
            guard !opened else {
                return
            }
            Task { @MainActor in
                coordinator.showToast(L10n.string("settings.open_settings_error"))
            }
        }
    }

    private func openParentGatedLink(_ rawURL: String) {
        guard let url = URL(string: rawURL) else {
            return
        }

        presentedParentGate = .privacyDeepLink(url)
    }
}

private struct SettingsHeaderView: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(DH.pinkDeep)
                    .frame(width: 44, height: 44)
                    .background(.white, in: Circle())
                    .chunkyShadow(.sm(deep: DH.pink), shape: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("common.back"))
            .accessibilityHint(L10n.string("common.back_hint"))

            Spacer()

            Text("settings.title")
                .font(DH.font(.headline))
                .tracking(DH.tracking(.headline))
                .foregroundStyle(DH.pinkDeep)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
    }
}

private struct SettingsAccountSection: View {
    let viewModel: SettingsViewModel
    let isPro: Bool
    let onEditAvatar: () -> Void
    let onUnlockPro: () -> Void

    var body: some View {
        SettingsGroup(title: L10n.string("settings.group.account")) {
            SettingsRow(
                icon: "person.fill",
                iconBackground: DH.pink,
                title: L10n.string("settings.account.display_name"),
                subtitle: viewModel.profile.displayName,
                trailing: { SettingsChevron() },
                onTap: onEditAvatar
            )

            SettingsDivider()

            SettingsRow(
                icon: "envelope.fill",
                iconBackground: DH.lavender,
                title: L10n.string("settings.account.parent_email"),
                subtitle: viewModel.parentEmailSummary
            )

            SettingsDivider()

            SettingsRow(
                icon: isPro ? "crown.fill" : "lock.fill",
                iconBackground: isPro ? DH.butter : DH.pinkLight,
                title: L10n.string("settings.account.studio_pro"),
                subtitle: isPro ? L10n.string("settings.account.pro_unlocked") : L10n.string("settings.account.pro_locked"),
                trailing: {
                    if isPro {
                        Text("👑")
                            .font(.system(size: 18))
                    } else {
                        SettingsChevron()
                    }
                },
                onTap: isPro ? nil : onUnlockPro
            )
        }
    }
}

private struct SettingsPrivacySection: View {
    @Bindable var viewModel: SettingsViewModel
    let onOpenSettings: () -> Void

    var body: some View {
        SettingsGroup(title: L10n.string("settings.group.privacy")) {
            SettingsRow(
                icon: "camera.fill",
                iconBackground: DH.pinkLight,
                title: L10n.string("settings.privacy.camera"),
                subtitle: viewModel.cameraGranted ? L10n.string("settings.allowed") : L10n.string("settings.permission_off"),
                trailing: { SettingsChevron() },
                onTap: onOpenSettings
            )

            SettingsDivider()

            SettingsRow(
                icon: "mic.fill",
                iconBackground: DH.butter,
                title: L10n.string("settings.privacy.microphone"),
                subtitle: viewModel.microphoneGranted ? L10n.string("settings.allowed") : L10n.string("settings.permission_off"),
                trailing: { SettingsChevron() },
                onTap: onOpenSettings
            )

            SettingsDivider()

            SettingsRow(
                icon: "photo.fill",
                iconBackground: DH.mint,
                title: L10n.string("settings.privacy.save_to_photos"),
                subtitle: viewModel.photosSummary,
                trailing: {
                    DHToggle(isOn: $viewModel.saveToPhotos)
                }
            )

            SettingsDivider()

            SettingsRow(
                icon: "square.and.arrow.up.fill",
                iconBackground: DH.lavender,
                title: L10n.string("settings.privacy.block_share_extensions"),
                subtitle: viewModel.blockShareExtensions
                    ? L10n.string("settings.privacy.share_stays_inside")
                    : L10n.string("settings.privacy.share_sheet_enabled"),
                trailing: {
                    DHToggle(isOn: $viewModel.blockShareExtensions)
                }
            )
        }
    }
}

private struct SettingsLookAndFeelSection: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        SettingsGroup(title: L10n.string("settings.group.look_and_feel")) {
            SettingsRow(
                icon: "sparkles",
                iconBackground: DH.pinkLight,
                title: L10n.string("settings.look_and_feel.theme"),
                subtitle: L10n.string("settings.look_and_feel.theme_value")
            )

            SettingsDivider()

            SettingsRow(
                icon: "speaker.wave.2.fill",
                iconBackground: DH.mint,
                title: L10n.string("settings.look_and_feel.sounds"),
                subtitle: viewModel.soundEnabled ? L10n.string("settings.look_and_feel.sounds_on") : L10n.string("common.off"),
                trailing: {
                    DHToggle(isOn: $viewModel.soundEnabled)
                }
            )

            SettingsDivider()

            SettingsRow(
                icon: "iphone.radiowaves.left.and.right",
                iconBackground: DH.lavender,
                title: L10n.string("settings.look_and_feel.haptics"),
                subtitle: viewModel.hapticsEnabled ? L10n.string("settings.look_and_feel.haptics_on") : L10n.string("common.off"),
                trailing: {
                    DHToggle(isOn: $viewModel.hapticsEnabled)
                }
            )
        }
    }
}

private struct SettingsAboutSection: View {
    let viewModel: SettingsViewModel
    let onOpenLink: (String) -> Void

    var body: some View {
        SettingsGroup(title: L10n.string("settings.group.about")) {
            SettingsRow(
                icon: "questionmark.circle.fill",
                iconBackground: DH.mint,
                title: L10n.string("settings.about.help_center"),
                trailing: { SettingsChevron() },
                onTap: { onOpenLink("https://grwmstudio.app/help") }
            )

            SettingsDivider()

            SettingsRow(
                icon: "hand.raised.fill",
                iconBackground: DH.butter,
                title: L10n.string("settings.about.privacy_policy"),
                trailing: { SettingsChevron() },
                onTap: { onOpenLink("https://grwmstudio.app/privacy") }
            )

            SettingsDivider()

            SettingsRow(
                icon: "doc.text.fill",
                iconBackground: DH.lavender,
                title: L10n.string("settings.about.terms"),
                trailing: { SettingsChevron() },
                onTap: { onOpenLink("https://grwmstudio.app/terms") }
            )

            SettingsDivider()

            SettingsRow(
                icon: "info.circle.fill",
                iconBackground: DH.pinkLight,
                title: L10n.string("settings.about.version"),
                subtitle: viewModel.versionString
            )
        }
    }
}

private struct SettingsDangerZoneSection: View {
    let onDelete: () -> Void

    var body: some View {
        SettingsGroup(title: L10n.string("settings.group.danger_zone")) {
            SettingsRow(
                icon: "trash.fill",
                iconBackground: DH.pinkLight,
                title: L10n.string("settings.danger.delete_all"),
                subtitle: L10n.string("settings.danger.delete_all_subtitle"),
                trailing: { SettingsChevron() },
                onTap: onDelete
            )
        }
    }
}

struct SettingsDivider: View {
    var body: some View {
        Divider()
            .overlay(DH.pinkPaper)
            .padding(.leading, 62)
    }
}

struct SettingsChevron: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(DH.pinkDeep)
    }
}
