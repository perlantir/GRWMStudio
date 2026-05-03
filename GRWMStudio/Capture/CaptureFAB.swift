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
        .animation(recordingPulse, value: isRecording)
        .contentShape(Circle())
        .allowsHitTesting(mode.isInteractive)
        .disabled(mode == .disabled)
        .accessibilityLabel(accessibilityLabel)
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

    private var recordingPulse: Animation? {
        isRecording ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default
    }

    private var accessibilityLabel: String {
        switch visualMode {
        case .idle:
            kind == .photo ? "Take photo" : "Start video recording"
        case .photoFiring:
            "Capturing photo"
        case .videoCountdown:
            "Get ready, recording starts in a moment"
        case .videoRecording:
            "Stop video recording"
        case .disabled:
            "Capture button disabled"
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
