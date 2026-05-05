import SwiftUI

struct CaptureFAB: View {
    let mode: CaptureMode
    let kind: CaptureKind
    let action: () -> Void

    var body: some View {
        Button {
            guard mode.isInteractive else {
                return
            }

            action()
        } label: {
            ZStack {
                buttonShape
                progressRing
                centerIcon
            }
        }
        .buttonStyle(.plain)
        .frame(width: 104, height: 104)
        .scaleEffect(pulseScale)
        .dhAnimation(.pulse, value: isRecording)
        .contentShape(Circle())
        .allowsHitTesting(mode.isInteractive)
        .disabled(mode == .disabled)
        .accessibilityLabel(L10n.string("capture.fab.accessibility_label"))
        .accessibilityValue(accessibilityValue)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
        .accessibilityIdentifier("capture-fab")
    }

    @ViewBuilder
    private var buttonShape: some View {
        switch visualMode {
        case .idle:
            switch kind {
            case .photo:
                circularButton(fill: DH.pinkDeep, shadow: DH.pinkDeep, ring: .white)
            case .video:
                circularButton(fill: DH.recRed, shadow: DH.recRedDeep, ring: .white)
            }

        case .photoFiring:
            circularButton(fill: .white, shadow: DH.pinkDeep, ring: DH.pinkDeep)

        case .videoCountdown, .videoRecording:
            recordingButton

        case .disabled:
            circularButton(fill: DH.cream, shadow: DH.pinkLight, ring: .white)
                .opacity(0.78)
        }
    }

    @ViewBuilder
    private var progressRing: some View {
        if case .videoRecording(let secondsElapsed) = visualMode, secondsElapsed > 0 {
            Circle()
                .stroke(DH.butter, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)
        }
    }

    private var recordingButton: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(DH.recRedDeep)
                .frame(width: 72, height: 72)
                .offset(y: 8)
                .shadow(color: DH.recRed.opacity(0.45), radius: 22, x: 0, y: 12)

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(DH.recRed)
                .frame(width: 72, height: 72)
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(.white, lineWidth: 4)
                }
        }
        .frame(width: 88, height: 88)
    }

    @ViewBuilder
    private var centerIcon: some View {
        switch visualMode {
        case .idle:
            Image(systemName: kind.systemName)
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(.white)
        case .photoFiring:
            Image(systemName: "camera.fill")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(DH.pinkDeep)
        case .videoCountdown:
            Image(systemName: "timer")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(.white)
        case .videoRecording:
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(.white)
                .frame(width: 28, height: 28)
        case .disabled:
            Image(systemName: "camera.fill")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(DH.pinkDeep.opacity(0.45))
        }
    }

    private var isRecording: Bool {
        if case .videoRecording = visualMode {
            return true
        }
        return false
    }

    private var pulseScale: CGFloat {
        isRecording ? 0.94 : 1
    }

    private var accessibilityValue: String {
        switch visualMode {
        case .idle:
            switch kind {
            case .photo:
                L10n.string("capture.fab.photo_mode")
            case .video:
                L10n.string("capture.fab.video_mode")
            }
        case .photoFiring:
            L10n.string("capture.fab.photo_capturing")
        case .videoCountdown:
            L10n.string("capture.fab.video_countdown")
        case .videoRecording:
            L10n.string("capture.fab.video_recording")
        case .disabled:
            L10n.string("common.disabled")
        }
    }

    private var accessibilityHint: String {
        switch visualMode {
        case .idle:
            switch kind {
            case .photo:
                L10n.string("capture.fab.photo_hint")
            case .video:
                L10n.string("capture.fab.video_hint")
            }
        case .photoFiring:
            L10n.string("capture.fab.photo_busy_hint")
        case .videoCountdown:
            L10n.string("capture.fab.video_countdown_hint")
        case .videoRecording:
            L10n.string("capture.fab.stop_hint")
        case .disabled:
            L10n.string("capture.fab.disabled_hint")
        }
    }

    private var visualMode: CaptureMode {
        mode
    }

    private func circularButton(fill: Color, shadow: Color, ring: Color) -> some View {
        ZStack {
            Circle()
                .fill(shadow)
                .frame(width: 88, height: 88)
                .offset(y: 8)
                .shadow(color: shadow.opacity(0.45), radius: 22, x: 0, y: 12)

            Circle()
                .fill(fill)
                .frame(width: 88, height: 88)
                .overlay {
                    Circle()
                        .strokeBorder(ring, lineWidth: 4)
            }
        }
        .frame(width: 88, height: 88)
    }
}

#Preview("Capture FAB") {
    HStack(spacing: 24) {
        CaptureFAB(mode: .idle, kind: .photo) {}
        CaptureFAB(mode: .idle, kind: .video) {}
        CaptureFAB(mode: .videoRecording(secondsElapsed: 5), kind: .video) {}
        CaptureFAB(mode: .disabled, kind: .photo) {}
    }
    .padding(32)
    .background(DH.pinkPaper)
}

struct RecordingOverlay: View {
    let secondsElapsed: Double
    var cap: Double?

    @State private var pulsing = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(.white)
                .frame(width: 12, height: 12)
                .scaleEffect(pulsing ? 1.05 : 1.0)
                .dhAnimation(.pulse, value: pulsing)
                .accessibilityHidden(true)

            Text("capture.recording.rec")
                .font(DH.font(.buttonSmall))
                .tracking(DH.tracking(.buttonSmall))

            Text(timeString)
                .font(DH.font(.buttonSmall))
                .tracking(DH.tracking(.buttonSmall))
                .foregroundStyle(approachingCap ? DH.butter : .white)
                .accessibilityIdentifier("recording-elapsed-label")
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background {
            Capsule()
                .fill(DH.recRed)
                .chunkyShadow(.sm(deep: DH.recRedDeep), shape: Capsule())
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(L10n.string("capture.recording.timer"))
        .accessibilityValue(timeString)
        .accessibilityIdentifier("recording-overlay")
        .onAppear {
            pulsing = true
        }
    }

    private var approachingCap: Bool {
        guard let cap else {
            return false
        }

        return (cap - secondsElapsed) <= 2.0
    }

    private var timeString: String {
        guard let cap else {
            return Self.format(secondsElapsed)
        }

        return "\(Self.format(secondsElapsed)) / \(Self.format(cap))"
    }

    private static func format(_ seconds: Double) -> String {
        let safeSeconds = max(0, Int(seconds.rounded(.down)))
        return String(format: "%d:%02d", safeSeconds / 60, safeSeconds % 60)
    }
}

struct RecordingStopChip: View {
    let action: () -> Void

    var body: some View {
        Button {
            DHHaptics.tapMedium()
            action()
        } label: {
            HStack(spacing: 7) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .heavy))

                Text("capture.recording.stop")
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
            }
            .foregroundStyle(DH.recRedDeep)
            .padding(.horizontal, 16)
            .frame(height: 34)
            .background {
                Capsule()
                    .fill(.white)
                    .chunkyShadow(.sm(deep: DH.recRedDeep), shape: Capsule())
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.string("capture.recording.stop_accessibility_label"))
        .accessibilityHint(L10n.string("capture.recording.stop_accessibility_hint"))
        .accessibilityIdentifier("recording-stop-chip")
    }
}

struct SaveFailureBanner: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 17, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(DH.recRedDeep))

            VStack(alignment: .leading, spacing: 2) {
                Text("capture.save_failure.title")
                    .font(DH.font(.buttonSmall))
                    .tracking(DH.tracking(.buttonSmall))
                    .foregroundStyle(DH.ink)

                Text("capture.save_failure.subtitle")
                    .font(DH.font(.caption))
                    .tracking(DH.tracking(.caption))
                    .foregroundStyle(DH.ink.opacity(0.72))
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: DH.Radius.card)
                .fill(.white.opacity(0.96))
                .chunkyShadow(.sm(deep: DH.recRedDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.card))
        }
        .accessibilityIdentifier("save-fail-banner")
    }
}

struct SavedConfetti: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let onComplete: @MainActor () -> Void
    @State private var phase: CGFloat = 0

    var body: some View {
        ZStack {
            Color.white.opacity(0.58)
                .ignoresSafeArea()

            ForEach(0..<12, id: \.self) { index in
                StickerHeart(
                    size: index.isMultiple(of: 3) ? 34 : 26,
                    fill: index.isMultiple(of: 2) ? DH.pinkDeep : DH.butter
                )
                .offset(
                    x: xOffset(for: index),
                    y: yOffset(for: index) - 210 * phase
                )
                .opacity(1 - phase)
                .rotationEffect(.degrees(Double(index * 30) + Double(phase * 90)))
            }

            VStack(spacing: 10) {
                Text("capture.saved.title")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)
                    .scaleEffect(1 + 0.1 * phase)

                StickerStar(size: 34, fill: DH.butter)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
            .background {
                RoundedRectangle(cornerRadius: DH.Radius.bigCard)
                    .fill(.white)
                    .chunkyShadow(.lg(deep: DH.pinkDeep), shape: RoundedRectangle(cornerRadius: DH.Radius.bigCard))
            }
        }
        .accessibilityIdentifier("saved-confetti")
        .task {
            Sounds.confetti.play()
            DHHaptics.success()
            withAnimation(DHAnim.respecting(.celebrate, reduceMotion: reduceMotion)) {
                phase = 1
            }
            try? await Task.sleep(for: .milliseconds(1_200))
            onComplete()
        }
    }

    private func xOffset(for index: Int) -> CGFloat {
        CGFloat((index * 43) % 240) - 120
    }

    private func yOffset(for index: Int) -> CGFloat {
        CGFloat((index * 29) % 80) - 40
    }
}
