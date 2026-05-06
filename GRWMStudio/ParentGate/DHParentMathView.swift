import SwiftUI

struct DHParentMathView: View {
    @Bindable var coordinator: ParentGateCoordinator

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                topBar
                mathCard
                    .padding(.horizontal, 18)
                    .padding(.top, 34)

                numpad
                    .padding(.horizontal, 18)
                    .padding(.top, 18)

                Spacer(minLength: 0)
            }
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(colors: [DH.pinkLight, DH.pinkPaper], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            StickerHeart(size: 124, fill: DH.pink.opacity(0.3), stroke: .clear)
                .rotationEffect(.degrees(-18))
                .position(x: 54, y: 214)

            StickerHeart(size: 148, fill: DH.pinkDeep.opacity(0.2), stroke: .clear)
                .rotationEffect(.degrees(16))
                .position(x: UIScreen.main.bounds.width - 54, y: UIScreen.main.bounds.height - 228)
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

    private var mathCard: some View {
        DHCard(bg: .white, deep: DH.pinkDeep, cornerRadius: 28, padding: 24) {
            VStack(spacing: 0) {
                Text("👋")
                    .font(.system(size: 46))

                Text("parent_gate.math.title")
                    .font(DH.font(.display3))
                    .tracking(DH.tracking(.display3))
                    .foregroundStyle(DH.pinkDeep)
                    .multilineTextAlignment(.center)

                Text("parent_gate.math.subtitle")
                    .font(DH.font(.body))
                    .tracking(DH.tracking(.body))
                    .foregroundStyle(DH.ink.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)

                if case .math(let challenge, let attempts, let lockedUntil) = coordinator.phase {
                    HStack(spacing: 10) {
                        MathChip(value: "\(challenge.lhs)", hollow: false)
                        Text("+")
                            .font(DH.font(.headline))
                            .tracking(DH.tracking(.headline))
                            .foregroundStyle(DH.pinkDeep)
                        MathChip(value: "\(challenge.rhs)", hollow: false)
                        Text("=")
                            .font(DH.font(.headline))
                            .tracking(DH.tracking(.headline))
                            .foregroundStyle(DH.pinkDeep)
                        MathChip(value: "?", hollow: true)
                    }
                    .padding(.top, 20)

                    EntryField(
                        text: coordinator.entry.isEmpty ? "___" : coordinator.entry,
                        wrong: attempts > 0 && coordinator.entry.isEmpty && lockedUntil == nil
                    )
                    .padding(.top, 20)
                    .accessibilityLabel(L10n.string("parent_gate.math.answer_field"))

                    if attempts > 0, coordinator.entry.isEmpty, lockedUntil == nil {
                        HStack(spacing: 8) {
                            Text("🙊")
                            Text("parent_gate.math.wrong")
                                .font(DH.font(.caption))
                                .tracking(DH.tracking(.caption))
                                .foregroundStyle(DH.recRedDeep)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(DH.pinkPaper, in: RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 10)
                    }

                    if let lockedUntil, lockedUntil > Date() {
                        Text(verbatim: L10n.format("parent_gate.math.locked", coordinator.remainingLockSeconds))
                            .font(DH.font(.caption))
                            .tracking(DH.tracking(.caption))
                            .foregroundStyle(DH.pinkDeep)
                            .multilineTextAlignment(.center)
                            .padding(.top, 12)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var numpad: some View {
        let keys: [NumpadKey] = [
            .digit(1), .digit(2), .digit(3),
            .digit(4), .digit(5), .digit(6),
            .digit(7), .digit(8), .digit(9),
            .backspace, .digit(0), .okay
        ]

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(keys, id: \.id) { key in
                Button {
                    switch key {
                    case .digit(let value):
                        Sounds.bubble.play()
                        DHHaptics.light()
                        coordinator.appendDigit(value)
                    case .backspace:
                        DHHaptics.light()
                        coordinator.backspace()
                    case .okay:
                        DHHaptics.medium()
                        coordinator.submitMath()
                    }
                } label: {
                    Text(key.label)
                        .font(DH.font(key == .okay ? .buttonLarge : .headline))
                        .tracking(DH.tracking(key == .okay ? .buttonLarge : .headline))
                        .foregroundStyle(key == .okay ? .white : DH.pinkDeep)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(key == .okay ? DH.pink : .white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .chunkyShadow(.sm(deep: key == .okay ? DH.pinkDeep : DH.pinkLight), shape: RoundedRectangle(cornerRadius: 18))
                }
                .buttonStyle(.plain)
                .disabled(coordinator.isLocked)
                .opacity(coordinator.isLocked ? 0.5 : 1)
                .accessibilityLabel(key.accessibilityLabel)
                .accessibilityIdentifier("parent-gate-\(key.id)")
            }
        }
    }
}

private enum NumpadKey: Equatable {
    case digit(Int)
    case backspace
    case okay

    var id: String {
        switch self {
        case .digit(let value):
            "digit-\(value)"
        case .backspace:
            "backspace"
        case .okay:
            "okay"
        }
    }

    var label: String {
        switch self {
        case .digit(let value):
            "\(value)"
        case .backspace:
            "⌫"
        case .okay:
            "OK"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .digit(let value):
            "\(value)"
        case .backspace:
            L10n.string("parent_gate.math.backspace")
        case .okay:
            L10n.string("common.ok")
        }
    }
}

private struct EntryField: View {
    let text: String
    let wrong: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(text)
                .font(DH.font(.display3))
                .tracking(DH.tracking(.display3))
                .foregroundStyle(wrong ? DH.recRed : DH.pinkDeep)

            Spacer()

            Text("parent_gate.math.your_answer")
                .font(DH.font(.caption))
                .tracking(DH.tracking(.caption))
                .foregroundStyle(DH.ink.opacity(0.5))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(DH.pinkPaper, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(wrong ? DH.recRed : DH.pinkLight, lineWidth: 3)
        }
        .shadow(color: (wrong ? DH.recRedDeep : DH.pinkLight).opacity(0.4), radius: 0, x: 0, y: 4)
    }
}
