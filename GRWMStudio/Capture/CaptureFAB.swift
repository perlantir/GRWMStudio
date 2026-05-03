import SwiftUI

struct CaptureFAB: View {
    let mode: CaptureMode
    let onTap: () -> Void
    let onLongPressBegan: () -> Void
    let onLongPressEnded: (Double) -> Void

    @State private var pressStart: Date?
    @State private var pressDuration: Double = 0
    @State private var didBeginLongPress = false
    @State private var isLongPressActive = false
    @State private var progressTask: Task<Void, Never>?

    private let classifier = CapturePressClassifier()

    var body: some View {
        ZStack {
            buttonShape
            progressRing
        }
        .frame(width: 104, height: 104)
        .scaleEffect(pulseScale)
        .animation(recordingPulse, value: isRecording)
        .contentShape(Circle())
        .gesture(combinedGesture)
        .allowsHitTesting(mode.isInteractive)
        .disabled(mode == .disabled)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(.isButton)
        .onDisappear(perform: cancelPressTracking)
    }

    @ViewBuilder
    private var buttonShape: some View {
        switch visualMode {
        case .idle:
            circularButton(fill: DH.pinkDeep, shadow: DH.pinkDeep, ring: .white)

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
        if progressValue > 0 {
            Circle()
                .trim(from: 0, to: progressValue)
                .stroke(DH.butter, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
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

    private var progressValue: CGFloat {
        let seconds: Double
        switch visualMode {
        case .videoRecording(let secondsElapsed):
            seconds = secondsElapsed
        default:
            seconds = pressStart == nil ? 0 : pressDuration
        }

        guard seconds > 0 else {
            return 0
        }

        return CGFloat(min(seconds / CapturePressClassifier.maxVideoDuration, 1))
    }

    private var combinedGesture: some Gesture {
        let longPress = LongPressGesture(minimumDuration: CapturePressClassifier.longPressThreshold)
            .onEnded { _ in
                guard mode.isInteractive else {
                    return
                }

                didBeginLongPress = true
                isLongPressActive = true
                onLongPressBegan()
            }

        let drag = DragGesture(minimumDistance: 0)
            .onChanged { _ in
                beginPressIfNeeded()
            }
            .onEnded { _ in
                finishPress()
            }

        return longPress.simultaneously(with: drag)
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
            "Capture. Tap for photo, hold for video"
        case .photoFiring:
            "Capturing photo"
        case .videoCountdown:
            "Get ready, recording starts in a moment"
        case .videoRecording:
            "Recording video, release to stop"
        case .disabled:
            "Capture button disabled"
        }
    }

    private var visualMode: CaptureMode {
        guard isLongPressActive else {
            return mode
        }

        return .videoRecording(secondsElapsed: pressDuration)
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

    private func beginPressIfNeeded() {
        guard mode.isInteractive, pressStart == nil else {
            return
        }

        pressStart = Date()
        pressDuration = 0
        didBeginLongPress = false
        startProgressTask()
    }

    private func finishPress() {
        guard mode.isInteractive, let pressStart else {
            cancelPressTracking()
            return
        }

        let duration = min(Date().timeIntervalSince(pressStart), CapturePressClassifier.maxVideoDuration)
        let event = classifier.event(for: duration)

        switch event {
        case .photoCapture:
            onTap()
        case .videoCapture(let duration):
            if !didBeginLongPress {
                onLongPressBegan()
            }
            onLongPressEnded(duration)
        }

        cancelPressTracking()
    }

    private func startProgressTask() {
        progressTask?.cancel()
        progressTask = Task { @MainActor in
            while !Task.isCancelled {
                if let pressStart {
                    pressDuration = min(Date().timeIntervalSince(pressStart), CapturePressClassifier.maxVideoDuration)
                }
                try? await Task.sleep(for: .milliseconds(33))
            }
        }
    }

    private func cancelPressTracking() {
        progressTask?.cancel()
        progressTask = nil
        pressStart = nil
        pressDuration = 0
        didBeginLongPress = false
        isLongPressActive = false
    }
}

#Preview("Capture FAB") {
    HStack(spacing: 24) {
        CaptureFAB(mode: .idle) {} onLongPressBegan: {} onLongPressEnded: { _ in }
        CaptureFAB(mode: .videoRecording(secondsElapsed: 5)) {} onLongPressBegan: {} onLongPressEnded: { _ in }
        CaptureFAB(mode: .disabled) {} onLongPressBegan: {} onLongPressEnded: { _ in }
    }
    .padding(32)
    .background(DH.pinkPaper)
}
