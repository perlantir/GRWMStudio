import Foundation
import SwiftUI

enum CountdownStep: Int, CaseIterable, Equatable {
    case three = 3
    case two = 2
    case one = 1
    case goSignal = 0

    var label: String {
        switch self {
        case .three, .two, .one:
            "\(rawValue)"
        case .goSignal:
            "Go!"
        }
    }
}

@MainActor
struct CountdownSequenceRunner {
    let onStep: @MainActor (CountdownStep) async -> Void
    let onComplete: @MainActor () -> Void

    func run(isCancelled: @escaping @MainActor () -> Bool = { false }) async {
        for step in CountdownStep.allCases {
            guard !Task.isCancelled, !isCancelled() else {
                return
            }

            await onStep(step)
            guard !Task.isCancelled, !isCancelled() else {
                return
            }
        }

        guard !Task.isCancelled, !isCancelled() else {
            return
        }
        onComplete()
    }
}

struct CountdownOverlay: View {
    let onComplete: () -> Void
    let onCancel: () -> Void
    let stepDuration: TimeInterval
    let onTick: @MainActor (CountdownStep) -> Void

    @State private var step: CountdownStep = .three
    @State private var visible = false
    @State private var bubbleScale = 0.6
    @State private var didEnd = false
    @State private var countdownTask: Task<Void, Never>?

    init(
        onComplete: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        stepDuration: TimeInterval = 1,
        onTick: @escaping @MainActor (CountdownStep) -> Void = { _ in
            Sounds.countdownTick.play()
            DHHaptics.medium()
        }
    ) {
        self.onComplete = onComplete
        self.onCancel = onCancel
        self.stepDuration = stepDuration
        self.onTick = onTick
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(0.3)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture(perform: cancel)

            VStack(spacing: 16) {
                readyPill
                countdownBubble
                cancelPill
            }
        }
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            cancelCountdownTask()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Countdown to recording: \(step.label)")
        .accessibilityIdentifier("countdown-overlay")
    }

    private var readyPill: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(.white)
                .frame(width: 8, height: 8)

            Text("GET READY")
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(Capsule().fill(DH.pinkDeep))
        .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 3)
        .shadow(color: DH.pinkDeep.opacity(0.35), radius: 10, x: 0, y: 5)
    }

    private var countdownBubble: some View {
        ZStack {
            Circle()
                .fill(DH.pinkDeep)
                .frame(width: 200, height: 200)
                .offset(y: 10)
                .shadow(color: DH.pinkDeep.opacity(0.5), radius: 40, x: 0, y: 20)

            Circle()
                .fill(.white)
                .frame(width: 200, height: 200)
                .overlay {
                    Circle()
                        .strokeBorder(DH.pinkDeep, lineWidth: 8)
                }

            Text(step.label)
                .font(DH.font(.display1))
                .tracking(DH.tracking(.display1))
                .foregroundStyle(DH.pink)
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 6)
                .minimumScaleFactor(0.45)
                .lineLimit(1)
                .scaleEffect(step == .goSignal ? 0.78 : 1.42)

            StickerSparkle(size: 28, fill: DH.butter, stroke: .white, strokeWidth: 2.5)
                .offset(x: 88, y: -86)
                .rotationEffect(.degrees(12))

            StickerSparkle(size: 22, fill: DH.lavender, stroke: .white, strokeWidth: 2)
                .offset(x: -88, y: 82)
                .rotationEffect(.degrees(-15))
        }
        .scaleEffect(bubbleScale)
        .opacity(visible ? 1 : 0)
        .contentShape(Circle())
        .onTapGesture {}
    }

    private var cancelPill: some View {
        Button(action: cancel) {
            Text("Tap anywhere to cancel")
                .font(DH.font(.buttonSmall))
                .tracking(DH.tracking(.buttonSmall))
                .foregroundStyle(DH.pinkDeep)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(Capsule().fill(.white.opacity(0.86)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Cancel countdown")
        .accessibilityIdentifier("countdown-cancel-button")
    }

    private func startCountdown() {
        guard countdownTask == nil else {
            return
        }

        countdownTask = Task { @MainActor in
            for countdownStep in CountdownStep.allCases {
                guard !Task.isCancelled, !didEnd else {
                    return
                }

                show(countdownStep)

                try? await sleep(seconds: min(0.24, stepDuration * 0.24))
                guard !Task.isCancelled, !didEnd else {
                    return
                }

                settle()

                try? await sleep(seconds: max(0, stepDuration - 0.38))
                guard !Task.isCancelled, !didEnd else {
                    return
                }

                fade()

                try? await sleep(seconds: min(0.14, stepDuration * 0.14))
            }

            complete()
        }
    }

    private func show(_ countdownStep: CountdownStep) {
        guard !didEnd else {
            return
        }

        step = countdownStep
        onTick(countdownStep)
        visible = false
        bubbleScale = 0.6

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            visible = true
            bubbleScale = 1.1
        }
    }

    private func settle() {
        guard !didEnd else {
            return
        }

        withAnimation(.spring(response: 0.22, dampingFraction: 0.72)) {
            bubbleScale = 1.0
        }
    }

    private func fade() {
        guard !didEnd else {
            return
        }

        withAnimation(.easeIn(duration: 0.14)) {
            visible = false
            bubbleScale = 0.6
        }
    }

    private func complete() {
        guard !didEnd else {
            return
        }

        didEnd = true
        countdownTask = nil
        onComplete()
    }

    private func cancel() {
        guard !didEnd else {
            return
        }

        didEnd = true
        cancelCountdownTask()
        onCancel()
    }

    private func cancelCountdownTask() {
        countdownTask?.cancel()
        countdownTask = nil
    }

    private func sleep(seconds: TimeInterval) async throws {
        try await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
    }
}

#if DEBUG
struct CountdownOverlayDebugScreen: View {
    @State private var showCountdown = true
    @State private var status = "Counting"

    var body: some View {
        ZStack {
            debugBackdrop

            if showCountdown {
                CountdownOverlay(
                    onComplete: {
                        status = "Complete"
                        showCountdown = false
                    },
                    onCancel: {
                        status = "Canceled"
                        showCountdown = false
                    },
                    stepDuration: debugStepDuration
                )
            }

            if !showCountdown {
                VStack {
                    Spacer()
                    Text(status)
                        .font(DH.font(.buttonSmall))
                        .tracking(DH.tracking(.buttonSmall))
                        .foregroundStyle(DH.pinkDeep)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(.white.opacity(0.92)))
                        .shadow(color: DH.pink.opacity(0.35), radius: 10, x: 0, y: 5)
                        .padding(.bottom, 38)
                        .accessibilityIdentifier("countdown-debug-status")
                }
                .allowsHitTesting(false)
            }
        }
        .preferredColorScheme(.light)
    }

    private var debugBackdrop: some View {
        ZStack {
            DHWallpaperStripes()
                .ignoresSafeArea()

            RoundedRectangle(cornerRadius: DH.Radius.viewport)
                .fill(
                    LinearGradient(
                        colors: [DH.pink, DH.pinkDeep],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: DH.pinkDeep, radius: 0, x: 0, y: 6)
                .shadow(color: DH.pinkDeep.opacity(0.4), radius: 26, x: 0, y: 12)
                .overlay {
                    RoundedRectangle(cornerRadius: DH.Radius.viewportInner)
                        .fill(
                            RadialGradient(
                                colors: [DH.cream, DH.pinkLight],
                                center: .center,
                                startRadius: 10,
                                endRadius: 280
                            )
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: DH.Radius.viewportInner)
                                .strokeBorder(.white, lineWidth: 6)
                        }
                        .padding(10)
                }
                .frame(height: 560)
                .padding(.horizontal, 18)
                .padding(.top, 72)
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var debugStepDuration: TimeInterval {
        ProcessInfo.processInfo.arguments.contains("-GRWMDebugCountdownSlow") ? 5 : 1
    }
}
#endif
