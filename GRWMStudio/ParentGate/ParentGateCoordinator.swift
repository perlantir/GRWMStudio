import Foundation
import Observation

enum ParentGateVariant {
    case math
    case hold
}

enum ParentGatePhase: Equatable {
    case math(challenge: MathChallenge, attempts: Int, lockedUntil: Date?)
    case hold(progress: Double, secondsElapsed: Double)
    case passed
}

struct MathChallenge: Equatable {
    let lhs: Int
    let rhs: Int

    var answer: Int {
        lhs + rhs
    }

    static func random() -> MathChallenge {
        MathChallenge(
            lhs: Int.random(in: 5 ... 12),
            rhs: Int.random(in: 4 ... 9)
        )
    }
}

@MainActor
@Observable
final class ParentGateCoordinator {
    let intent: ParentGateIntent
    let variant: ParentGateVariant

    var phase: ParentGatePhase
    var entry = ""
    var idleTimerExpired = false

    private let onPass: (ParentGateIntent) -> Void
    private let onCancel: () -> Void
    private var idleTask: Task<Void, Never>?
    private var lockoutTask: Task<Void, Never>?

    init(
        intent: ParentGateIntent,
        variantOverride: ParentGateVariant? = nil,
        onPass: @escaping (ParentGateIntent) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.intent = intent
        self.onPass = onPass
        self.onCancel = onCancel

        let variant: ParentGateVariant
        if let variantOverride {
            variant = variantOverride
        } else if ProcessInfo.processInfo.arguments.contains("-GRWMDebugParentGateMath") {
            variant = .math
        } else if ProcessInfo.processInfo.arguments.contains("-GRWMDebugParentGateHold") {
            variant = .hold
        } else {
            variant = Bool.random() ? .math : .hold
        }
        self.variant = variant

        switch variant {
        case .math:
            let challenge = ProcessInfo.processInfo.arguments.contains("-GRWMDebugParentGateMath")
                ? MathChallenge(lhs: 12, rhs: 5)
                : .random()
            phase = .math(challenge: challenge, attempts: 0, lockedUntil: nil)
        case .hold:
            phase = .hold(progress: 0, secondsElapsed: 0)
        }

        startIdleWatch()
    }

    var isLocked: Bool {
        guard case .math(_, _, let lockedUntil) = phase, let lockedUntil else {
            return false
        }
        return lockedUntil > Date()
    }

    var remainingLockSeconds: Int {
        guard case .math(_, _, let lockedUntil) = phase, let lockedUntil else {
            return 0
        }
        return max(0, Int(ceil(lockedUntil.timeIntervalSinceNow)))
    }

    func cancel() {
        idleTask?.cancel()
        lockoutTask?.cancel()
        onCancel()
    }

    func touchActivity() {
        resetIdleWatch()
    }

    func appendDigit(_ digit: Int) {
        guard case .math = phase, !isLocked else { return }
        guard entry.count < 3 else { return }
        entry.append("\(digit)")
        touchActivity()
    }

    func backspace() {
        guard case .math = phase, !isLocked else { return }
        guard !entry.isEmpty else { return }
        entry.removeLast()
        touchActivity()
    }

    func submitMath() {
        guard case .math(let challenge, let attempts, _) = phase, !isLocked else { return }
        guard let value = Int(entry) else { return }

        if value == challenge.answer {
            phase = .passed
            DHHaptics.shared.fire(.saved)
            onPass(intent)
            return
        }

        let nextAttempts = attempts + 1
        entry = ""
        DHHaptics.shared.fire(.errorSoft)

        if nextAttempts >= 3 {
            let lockedUntil = Date().addingTimeInterval(30)
            phase = .math(challenge: .random(), attempts: nextAttempts, lockedUntil: lockedUntil)
            startLockoutCountdown(until: lockedUntil)
        } else {
            phase = .math(challenge: .random(), attempts: nextAttempts, lockedUntil: nil)
        }
    }

    func updateHold(progress: Double, twoFingers: Bool) {
        guard case .hold = phase else { return }
        guard twoFingers else {
            resetHold()
            return
        }

        let clamped = min(1, max(0, progress))
        let secondsElapsed = clamped * 3
        phase = .hold(progress: clamped, secondsElapsed: secondsElapsed)

        if clamped >= 1 {
            phase = .passed
            DHHaptics.shared.fire(.saved)
            onPass(intent)
        } else {
            touchActivity()
        }
    }

    func resetHold() {
        phase = .hold(progress: 0, secondsElapsed: 0)
    }

    private func startIdleWatch() {
        idleTask?.cancel()
        idleTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(30))
            } catch {
                return
            }
            guard let self else { return }
            await MainActor.run {
                self.idleTimerExpired = true
                self.onCancel()
            }
        }
    }

    private func resetIdleWatch() {
        startIdleWatch()
    }

    private func startLockoutCountdown(until: Date) {
        lockoutTask?.cancel()
        lockoutTask = Task { [weak self] in
            while let self, Date() < until {
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    return
                }
                await MainActor.run {
                    if case .math(let challenge, let attempts, _) = self.phase {
                        self.phase = .math(challenge: challenge, attempts: attempts, lockedUntil: until)
                    }
                }
            }

            guard let self else { return }
            await MainActor.run {
                self.phase = .math(challenge: .random(), attempts: 0, lockedUntil: nil)
                self.entry = ""
            }
        }
    }
}
