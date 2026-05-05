import SwiftUI

#if DEBUG
struct ErrorTriggerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.rootCoordinator) private var coordinator
    @State private var previewVariant: ErrorVariant?

    var body: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(ErrorVariant.allCases) { variant in
                        DHCard(bg: .white, deep: variant.tone.deep.opacity(0.7), cornerRadius: 22, padding: 16) {
                            HStack(spacing: 14) {
                                Text(variant.emoji)
                                    .font(.system(size: 30))
                                    .frame(width: 54, height: 54)
                                    .background(variant.tone.hero.opacity(0.22), in: Circle())

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(variant.chipTitle)
                                        .font(DH.font(.microLabel))
                                        .tracking(DH.tracking(.microLabel))
                                        .foregroundStyle(DH.ink.opacity(0.55))

                                    Text(variant.title)
                                        .font(DH.font(.headline))
                                        .tracking(DH.tracking(.headline))
                                        .foregroundStyle(DH.ink)
                                }

                                Spacer(minLength: 12)

                                DHButton(title: L10n.string("settings.developer.trigger"), kind: .ghost, size: .sm) {
                                    previewVariant = variant
                                }
                                .accessibilityIdentifier("error-trigger-\(variant.rawValue)")
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 24)
                .padding(.bottom, 28)
            }
        }
        .fullScreenCover(item: $previewVariant) { variant in
            DHErrorView(
                variant: variant,
                onCTA: {
                    previewVariant = nil
                    ErrorRouter.handleCTA(variant, coordinator: coordinator)
                },
                onAlt: {
                    previewVariant = nil
                    ErrorRouter.handleAlt(variant, coordinator: coordinator)
                },
                onClose: {
                    previewVariant = nil
                }
            )
        }
        .navigationTitle(L10n.string("settings.developer.error_trigger_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(L10n.string("common.done")) {
                    dismiss()
                }
            }
        }
    }
}
#endif
