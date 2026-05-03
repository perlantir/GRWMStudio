import SwiftUI

struct MirrorBottomControls: View {
    @Bindable var viewModel: MirrorViewModel

    var body: some View {
        HStack(spacing: DH.Spacing.itemGap) {
            ControlButton(systemName: "arrow.triangle.2.circlepath.camera", tint: DH.pinkDeep) {
                Task { @MainActor in
                    await viewModel.flipCamera()
                }
            }
            .accessibilityLabel("Flip camera")

            ControlButton(
                systemName: viewModel.flashEnabled ? "bolt.fill" : "bolt",
                tint: viewModel.flashEnabled ? DH.butter : DH.pinkDeep
            ) {
                viewModel.toggleFlash()
            }
            .accessibilityLabel(viewModel.flashEnabled ? "Flash on" : "Flash off")

            Spacer(minLength: 0)
        }
        .padding(.horizontal, DH.Spacing.hPad)
    }
}

private struct ControlButton: View {
    let systemName: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.white))
                .chunkyShadow(.sm(deep: DH.pink), shape: Circle())
                .frame(width: 44, height: 50)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Mirror Bottom Controls") {
    @Previewable @State var viewModel = MirrorViewModel()

    ZStack {
        DHWallpaperGradient()
        MirrorBottomControls(viewModel: viewModel)
    }
}
