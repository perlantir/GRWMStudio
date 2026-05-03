import SwiftData
import SwiftUI

struct ParentInfoView: View {
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(\.modelContext) private var modelContext
    @State private var displayName = "Star"
    @State private var parentEmail = ""
    @State private var emailLooksInvalid = false
    @FocusState private var focusedField: Field?

    private enum Field {
        case name
        case email
    }

    var body: some View {
        ZStack {
            DHWallpaperStripes(stripeWidth: 30, secondaryStripeWidth: 2, opacity: 0.7)

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, DH.Spacing.hPad)
                    .padding(.top, 4)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        heroCard
                        formCard
                        privacyCopy
                    }
                    .padding(.horizontal, DH.Spacing.hPad)
                    .padding(.top, 14)
                    .padding(.bottom, 18)
                }

                buttonStack
                    .padding(.horizontal, DH.Spacing.hPad)
                    .padding(.bottom, 24)
            }
        }
        .preferredColorScheme(.light)
    }

    private var topBar: some View {
        HStack {
            Button {
                coordinator.showWelcome()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DH.pinkDeep)
                    .frame(width: 42, height: 42)
                    .background {
                        Circle()
                            .fill(.white)
                            .chunkyShadow(.sm(deep: DH.pink), shape: Circle())
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Spacer()

            Text("STEP 1 OF 3")
                .font(DH.font(.caption))
                .tracking(0.16 * DH.TypeStyle.caption.size)
                .foregroundStyle(DH.pinkDeep)

            Spacer()

            Color.clear
                .frame(width: 42, height: 42)
        }
    }

    private var heroCard: some View {
        DHCard(bg: .white, deep: DH.pink, cornerRadius: 28, padding: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text("👋")
                        .font(.system(size: 42))
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("HI, GROWN-UP")
                            .font(DH.font(.caption))
                            .tracking(0.16 * DH.TypeStyle.caption.size)
                            .foregroundStyle(DH.ink.opacity(0.5))

                        Text("A quick check-in")
                            .font(DH.font(.headline))
                            .tracking(DH.tracking(.headline))
                            .foregroundStyle(DH.pinkDeep)
                    }
                }

                Text("Choose a star name for this device. A grown-up's email is optional and stays private.")
                    .font(DH.font(.body))
                    .foregroundStyle(DH.ink.opacity(0.75))
                    .lineSpacing(4)
            }
        }
    }

    private var formCard: some View {
        DHCard(bg: DH.cream, deep: DH.pinkLight, cornerRadius: DH.Radius.card, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                labeledTextField(
                    label: "STAR NAME",
                    placeholder: "Star",
                    text: $displayName,
                    iconSystemName: "star.fill",
                    field: .name
                )

                VStack(alignment: .leading, spacing: 6) {
                    labeledTextField(
                        label: "GROWN-UP'S EMAIL - OPTIONAL",
                        placeholder: "parent@example.com",
                        text: $parentEmail,
                        iconSystemName: "envelope.fill",
                        field: .email,
                        keyboardType: .emailAddress
                    )

                    if emailLooksInvalid {
                        Text("Hmm, that doesn't look like an email - we'll skip it.")
                            .font(DH.font(.caption))
                            .tracking(DH.tracking(.caption))
                            .foregroundStyle(DH.recRed)
                    }

                    Text("Optional. Stored only as a private hash on this device.")
                        .font(DH.font(.caption))
                        .tracking(DH.tracking(.caption))
                        .foregroundStyle(DH.pinkDeep.opacity(0.65))
                }
            }
        }
    }

    private var privacyCopy: some View {
        Text("By continuing, GRWM may store this profile on this device. Parent email is optional, hashed locally, and never shared.")
            .font(DH.font(.caption))
            .foregroundStyle(DH.ink.opacity(0.55))
            .lineSpacing(4)
            .padding(.horizontal, 6)
    }

    private var buttonStack: some View {
        VStack(spacing: 12) {
            DHButton(
                title: "Continue",
                kind: .primary,
                size: .xl,
                trailingIcon: AnyView(Image(systemName: "arrow.right")),
                isFullWidth: true
            ) {
                save()
                coordinator.showPermissions()
            }
            .accessibilityLabel("Continue")

            DHButton(
                title: "Skip for now",
                kind: .ghost,
                size: .xl,
                isFullWidth: true
            ) {
                coordinator.showPermissions()
            }
            .accessibilityLabel("Skip for now")
        }
    }

    private func labeledTextField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        iconSystemName: String,
        field: Field,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(DH.font(.caption))
                .tracking(0.12 * DH.TypeStyle.caption.size)
                .foregroundStyle(DH.pinkDeep)

            HStack(spacing: 8) {
                Image(systemName: iconSystemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DH.pinkDeep)
                    .accessibilityHidden(true)

                TextField(placeholder, text: text)
                    .font(field == .name ? DH.font(.headline) : DH.font(.body))
                    .foregroundStyle(DH.ink)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(field == .email ? .never : .words)
                    .autocorrectionDisabled(field == .email)
                    .focused($focusedField, equals: field)
                    .submitLabel(field == .name ? .next : .done)
                    .onChange(of: parentEmail) { _, newValue in
                        normalizeEmail(newValue)
                    }
                    .accessibilityLabel(field == .name ? "Star name" : "Parent's email, optional")
            }
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(DH.pink.opacity(0.7), lineWidth: 2.5)
            }
            .shadow(color: DH.pink.opacity(0.7), radius: 0, x: 0, y: 3)
        }
    }

    private func normalizeEmail(_ newValue: String) {
        let lowercased = newValue.lowercased()
        if lowercased != newValue {
            parentEmail = lowercased
            return
        }

        emailLooksInvalid = !newValue.isEmpty && !ProfileRecord.looksLikeParentEmail(newValue)
    }

    private func save() {
        let descriptor = FetchDescriptor<ProfileRecord>()
        let existing = (try? modelContext.fetch(descriptor))?.first
        let record = existing ?? ProfileRecord(displayName: normalizedDisplayName)

        record.displayName = normalizedDisplayName
        record.parentEmailHashed = ProfileRecord.parentEmailHash(for: parentEmail)

        if existing == nil {
            modelContext.insert(record)
        }

        try? modelContext.save()
    }

    private var normalizedDisplayName: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Star" : trimmed
    }
}

#Preview("Parent Info") {
    ParentInfoView()
        .environment(\.rootCoordinator, RootCoordinator())
        .modelContainer(for: [SavedCapture.self, ProfileRecord.self, FavoriteLook.self], inMemory: true)
}
