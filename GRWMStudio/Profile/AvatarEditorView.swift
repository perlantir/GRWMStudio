import SwiftData
import SwiftUI

struct AvatarEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var viewModel: AvatarEditorViewModel?
    @State private var formOffset: CGFloat = 0
    @State private var selectedDetent: PresentationDetent = .fraction(0.72)

    let record: ProfileRecord
    let onSave: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if let viewModel {
                content(viewModel)
                    .offset(x: formOffset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .presentationDetents([.fraction(0.72), .large], selection: $selectedDetent)
        .presentationDragIndicator(.visible)
        .onAppear {
            if viewModel == nil {
                viewModel = AvatarEditorViewModel(context: modelContext, record: record)
            }
        }
        .onChange(of: viewModel?.validationShake ?? 0) { _, _ in
            shake()
        }
    }

    private func content(_ viewModel: AvatarEditorViewModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                navBar(viewModel)

                avatarPreview(viewModel.swatch)
                    .padding(.top, 4)

                swatchRow(viewModel)
                    .padding(.bottom, 6)

                editorField(
                    title: L10n.string("settings.account.display_name"),
                    text: Binding(
                        get: { viewModel.displayName },
                        set: { viewModel.setDisplayName($0) }
                    )
                )

                editorField(
                    title: L10n.string("profile.tagline"),
                    text: Binding(
                        get: { viewModel.tagline },
                        set: { viewModel.setTagline($0) }
                    )
                )

                Spacer(minLength: 12)
            }
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.horizontal, 18)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
    }

    private func navBar(_ viewModel: AvatarEditorViewModel) -> some View {
        HStack {
            Button(L10n.string("common.cancel")) { dismiss() }
                .font(DH.font(.body))
                .tracking(DH.tracking(.body))
                .foregroundStyle(DH.ink.opacity(0.65))

            Spacer()

            Text("profile.edit_avatar")
                .font(DH.font(.headline))
                .tracking(DH.tracking(.headline))
                .foregroundStyle(DH.pinkDeep)

            Spacer()

            Button(L10n.string("common.save")) {
                if viewModel.save() {
                    onSave()
                    dismiss()
                }
            }
            .font(DH.font(.bodyEmphasis))
            .tracking(DH.tracking(.bodyEmphasis))
            .foregroundStyle(DH.pinkDeep)
        }
    }

    private func swatchRow(_ viewModel: AvatarEditorViewModel) -> some View {
        HStack(spacing: 12) {
            ForEach(AvatarSwatch.allCases) { swatch in
                swatchButton(swatch, selected: viewModel.swatch == swatch) {
                    withAnimation(DHAnim.respecting(.quickPop, reduceMotion: reduceMotion)) {
                        viewModel.swatch = swatch
                    }
                    DHHaptics.light()
                    Sounds.bubble.play()
                }
            }
        }
    }

    private func swatchButton(_ swatch: AvatarSwatch, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(swatch.fill)
                .frame(width: 42, height: 42)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 3)
                }
                .overlay {
                    if selected {
                        Circle()
                            .stroke(DH.pinkDeep, lineWidth: 4)
                            .padding(-6)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.format("profile.avatar_swatch.accessibility_label", swatch.label))
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    private func avatarPreview(_ swatch: AvatarSwatch) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(swatch.fill)
                .frame(width: 114, height: 114)
                .overlay(Circle().stroke(.white, lineWidth: 5))
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 6)
                .shadow(color: DH.pinkDeep.opacity(0.35), radius: 16, x: 0, y: 10)
                .overlay {
                    Image(systemName: "face.smiling.inverse")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(swatch.accent)
                }

            StickerSparkle(size: 24, fill: .white)
                .padding(8)
        }
    }

    private func editorField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(DH.font(.caption))
                .tracking(DH.tracking(.caption))
                .foregroundStyle(DH.pinkDeep)

            TextField("", text: text)
                .font(DH.font(.headline))
                .tracking(DH.tracking(.headline))
                .foregroundStyle(DH.ink)
                .padding(.horizontal, 14)
                .frame(height: 48)
                .background(.white, in: RoundedRectangle(cornerRadius: 16))
                .chunkyShadow(.sm(deep: DH.pinkLight), shape: RoundedRectangle(cornerRadius: 16))
        }
    }

    private func shake() {
        formOffset = -10
        withAnimation(DHAnim.respecting(.track, reduceMotion: reduceMotion)) {
            formOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
            withAnimation(DHAnim.respecting(.snapFade, reduceMotion: reduceMotion)) {
                formOffset = -6
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.17) {
            withAnimation(DHAnim.respecting(.snapFade, reduceMotion: reduceMotion)) {
                formOffset = 0
            }
        }
    }
}
