import SwiftUI
import UIKit

struct SaveShareView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.rootCoordinator) private var coordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let capture: SavedCapture
    let captureURL: URL
    let onDone: () -> Void

    @State private var sharePayload: SharePayload?
    @State private var thumbnail: UIImage?
    @State private var errorMessage: String?
    @State private var lockerOnlyToastVisible = false
    @State private var presentedError: ErrorVariant?
    @State private var lockerOnlyToastTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkPaper, DH.cream], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                header
                    .padding(.top, 72)

                thumbnailCard

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    shareButton(L10n.string("save_share.camera_roll"), systemName: "photo.on.rectangle", fill: DH.pink) {
                        saveToCameraRoll()
                    }
                    shareButton(L10n.string("save_share.messages"), systemName: "message.fill", fill: DH.butter) {
                        presentShareSheet()
                    }
                    shareButton(L10n.string("save_share.email"), systemName: "envelope.fill", fill: DH.lavender) {
                        presentShareSheet()
                    }
                    shareButton(L10n.string("save_share.more"), systemName: "ellipsis", fill: DH.mint) {
                        presentShareSheet()
                    }
                }
                .padding(.horizontal, 18)

                DHButton(title: L10n.string("common.done"), kind: .ghost, size: .xl, isFullWidth: true, action: onDone)
                    .padding(.horizontal, 18)

                Spacer()
            }

            if lockerOnlyToastVisible {
                ToastView(message: L10n.string("save_share.locker_only_toast"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 118)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            if let presentedError {
                DHErrorView(
                    variant: presentedError,
                    onCTA: {
                        self.presentedError = nil
                        ErrorRouter.handleCTA(presentedError, coordinator: coordinator)
                    },
                    onAlt: {
                        self.presentedError = nil
                        ErrorRouter.handleAlt(presentedError, coordinator: coordinator)
                    },
                    onClose: {
                        self.presentedError = nil
                    }
                )
                .zIndex(10)
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityShareSheet(items: payload.items)
        }
        .alert(L10n.string("save_share.error.title"), isPresented: errorAlertBinding) {
            Button(L10n.string("common.ok"), role: .cancel) {}
        } message: {
            Text(errorMessage ?? L10n.string("common.something_went_wrong"))
        }
        .task {
            thumbnail = await ThumbnailLoader.shared.load(url: captureURL, kind: capture.kind)
        }
        .onReceive(NotificationCenter.default.publisher(for: .keepInsideGRWM)) { _ in
            showLockerOnlyToast()
        }
        .onDisappear {
            lockerOnlyToastTask?.cancel()
        }
    }

    private var header: some View {
        ZStack {
            StickerHeart(size: 28, fill: DH.pinkDeep, stroke: .white, strokeWidth: 3)
                .offset(x: -116, y: -8)
            StickerStar(size: 24, fill: DH.butter)
                .offset(x: 110, y: -18)
            StickerSparkle(size: 20, fill: DH.lavender)
                .offset(y: -30)

            Text("save_share.title")
                .font(DH.font(.display3))
                .tracking(DH.tracking(.display3))
                .foregroundStyle(DH.pinkDeep)
        }
    }

    private var thumbnailCard: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: DH.Radius.bigCard)
                .fill(.white)
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.bigCard))

            Group {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(colors: [DH.pinkLight, DH.pink, DH.pinkDeep], startPoint: .top, endPoint: .bottom)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DH.Radius.viewportInner))
            .padding(10)

            Text(capture.name)
                .font(DH.font(.buttonLarge))
                .tracking(DH.tracking(.buttonLarge))
                .foregroundStyle(DH.pinkDeep)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(.white.opacity(0.94), in: Capsule())
                .padding(.bottom, 16)
        }
        .frame(height: 320)
        .padding(.horizontal, 28)
    }

    private func shareButton(_ title: String, systemName: String, fill: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(title == L10n.string("save_share.camera_roll") ? .white : DH.ink)
                    .frame(width: 58, height: 58)
                    .background(
                        Circle()
                            .fill(fill)
                            .chunkyShadow(
                                .sm(deep: title == L10n.string("save_share.camera_roll") ? DH.pinkDeep : fill),
                                shape: Circle()
                            )
                    )

                Text(title)
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)
            }
            .frame(maxWidth: .infinity, minHeight: 112)
            .padding(.vertical, 10)
            .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: DH.Radius.card))
        }
        .buttonStyle(.plain)
    }

    private func presentShareSheet() {
        guard !SettingsPreferences.blockShareExtensions else {
            errorMessage = L10n.string("save_share.sharing_blocked")
            return
        }

        if let image = photoImage {
            sharePayload = SharePayload(items: [image])
        } else {
            sharePayload = SharePayload(items: [captureURL])
        }
    }

    private func saveToCameraRoll() {
        Task { @MainActor in
            let status = await env.permissions.photosAddStatus()

            switch status {
            case .denied, .restricted:
                presentedError = .photoDenied
                return
            case .notDetermined:
                let requested = await env.permissions.requestPhotosAdd()
                guard requested == .granted else {
                    presentedError = .photoDenied
                    return
                }
            case .granted:
                break
            }

            do {
                if let image = photoImage {
                    try await PhotoLibrarySaver().save(asset: .photo(image))
                } else {
                    try await PhotoLibrarySaver().save(asset: .video(captureURL))
                }
                DHHaptics.shared.fire(.saved)
                Sounds.confetti.play()
            } catch {
                if case .some(.photoAccessDenied) = error as? PreviewSaveError {
                    presentedError = .photoDenied
                } else {
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? L10n.string("save_share.photos_error")
                }
            }
        }
    }

    private func showLockerOnlyToast() {
        lockerOnlyToastTask?.cancel()

        withAnimation(DHAnim.respecting(.heroEmerge, reduceMotion: reduceMotion)) {
            lockerOnlyToastVisible = true
        }

        lockerOnlyToastTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.4))
            guard !Task.isCancelled else {
                return
            }

            withAnimation(DHAnim.respecting(.quickFade, reduceMotion: reduceMotion)) {
                lockerOnlyToastVisible = false
            }
        }
    }

    private var photoImage: UIImage? {
        guard capture.kind == .photo else {
            return nil
        }
        return UIImage(contentsOfFile: captureURL.path)
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { newValue in
                if !newValue {
                    errorMessage = nil
                }
            }
        )
    }
}

private struct SharePayload: Identifiable {
    let id = UUID()
    let items: [Any]
}
