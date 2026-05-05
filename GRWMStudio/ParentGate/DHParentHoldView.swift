import SwiftUI

struct DHParentHoldView: View {
    @Bindable var coordinator: ParentGateCoordinator

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                topBar
                titleBlock
                    .padding(.horizontal, 22)
                    .padding(.top, 30)

                heartZone
                    .padding(.top, 34)

                counter
                    .padding(.top, 22)

                Spacer(minLength: 0)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkLight, DH.pinkPaper], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            StickerHeart(size: 128, fill: DH.pink.opacity(0.28), stroke: .clear)
                .rotationEffect(.degrees(-16))
                .position(x: 56, y: 214)

            StickerHeart(size: 156, fill: DH.pinkDeep.opacity(0.16), stroke: .clear)
                .rotationEffect(.degrees(18))
                .position(x: UIScreen.main.bounds.width - 48, y: UIScreen.main.bounds.height - 218)
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                DHHaptics.light()
                coordinator.cancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(DH.pinkDeep)
                    .frame(width: 44, height: 44)
                    .background(.white, in: Circle())
                    .chunkyShadow(.sm(deep: DH.pink), shape: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.string("parent_gate.close"))
            .accessibilityHint(L10n.string("parent_gate.close.hint"))

            Spacer()

            Text("parent_gate.eyebrow")
                .font(DH.font(.microLabel))
                .tracking(DH.tracking(.microLabel))
                .foregroundStyle(DH.pinkDeep)

            Spacer()

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }

    private var titleBlock: some View {
        VStack(spacing: 8) {
            Text("👆")
                .font(.system(size: 48))

            Text("parent_gate.hold.title")
                .font(DH.font(.display3))
                .tracking(DH.tracking(.display3))
                .foregroundStyle(DH.pinkDeep)
                .multilineTextAlignment(.center)

            Text("parent_gate.hold.subtitle")
                .font(DH.font(.body))
                .tracking(DH.tracking(.body))
                .foregroundStyle(DH.ink.opacity(0.72))
                .multilineTextAlignment(.center)
        }
    }

    private var heartZone: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.95), lineWidth: 14)
                .frame(width: 240, height: 240)

            Circle()
                .trim(from: 0, to: holdProgress)
                .stroke(DH.pinkDeep, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 240, height: 240)
                .dhAnimation(.track, value: holdProgress)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [DH.pinkLight, DH.pink],
                        center: .topLeading,
                        startRadius: 12,
                        endRadius: 140
                    )
                )
                .frame(width: 200, height: 200)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 6)
                }
                .chunkyShadow(.lg(deep: DH.pinkDeep), shape: Circle())
                .overlay {
                    StickerHeart(size: 108, fill: .white, stroke: DH.pinkDeep, strokeWidth: 3)
                }
                .scaleEffect(holdProgress >= 1 ? 1.06 : 1)
                .dhAnimation(.quickPop, value: holdProgress >= 1)

            TwoFingerHoldGesture(
                onProgress: { progress, twoFingers in
                    coordinator.updateHold(progress: progress, twoFingers: twoFingers)
                },
                onReset: {
                    coordinator.resetHold()
                }
            )
            .frame(width: 240, height: 240)
        }
        .frame(width: 240, height: 240)
    }

    private var counter: some View {
        Text(String(format: "%.1fs", secondsElapsed))
            .font(.custom("Fredoka-Bold", size: 42))
            .foregroundStyle(DH.pinkDeep)
            .accessibilityLabel(L10n.format("parent_gate.hold.seconds", secondsElapsed.formatted(.number.precision(.fractionLength(1)))))
    }

    private var holdProgress: Double {
        guard case .hold(let progress, _) = coordinator.phase else {
            return 0
        }
        return progress
    }

    private var secondsElapsed: Double {
        guard case .hold(_, let secondsElapsed) = coordinator.phase else {
            return 3
        }
        return secondsElapsed
    }
}
