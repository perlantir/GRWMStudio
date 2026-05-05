import SwiftUI
import UIKit

protocol TouchTrackingViewDelegate: AnyObject {
    func touchCountDidChange(_ count: Int)
}

final class TouchTrackingView: UIView {
    weak var delegate: TouchTrackingViewDelegate?
    private var activeTouchIDs = Set<ObjectIdentifier>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTouches(touches, isAdding: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTouches(touches, isAdding: false)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTouches(touches, isAdding: false)
    }

    private func updateTouches(_ touches: Set<UITouch>, isAdding: Bool) {
        for touch in touches {
            let id = ObjectIdentifier(touch)
            if isAdding {
                activeTouchIDs.insert(id)
            } else {
                activeTouchIDs.remove(id)
            }
        }
        delegate?.touchCountDidChange(activeTouchIDs.count)
    }
}

struct TwoFingerHoldGesture: UIViewRepresentable {
    let onProgress: (Double, Bool) -> Void
    let onReset: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onProgress: onProgress, onReset: onReset)
    }

    func makeUIView(context: Context) -> TouchTrackingView {
        let view = TouchTrackingView()
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: TouchTrackingView, context: Context) {}

    final class Coordinator: NSObject, TouchTrackingViewDelegate {
        private let onProgress: (Double, Bool) -> Void
        private let onReset: () -> Void
        private var startedAt: Date?
        private var displayLink: CADisplayLink?

        init(onProgress: @escaping (Double, Bool) -> Void, onReset: @escaping () -> Void) {
            self.onProgress = onProgress
            self.onReset = onReset
        }

        func touchCountDidChange(_ count: Int) {
            if count >= 2 {
                startTracking()
            } else {
                stopTracking(reset: true)
            }
        }

        @objc
        private func tick() {
            guard let startedAt else { return }
            let elapsed = Date().timeIntervalSince(startedAt)
            let progress = min(1, max(0, elapsed / 3))
            onProgress(progress, true)
            if progress >= 1 {
                stopTracking(reset: false)
            }
        }

        private func startTracking() {
            guard displayLink == nil else { return }
            startedAt = Date()
            let displayLink = CADisplayLink(target: self, selector: #selector(tick))
            displayLink.add(to: .main, forMode: .common)
            self.displayLink = displayLink
        }

        private func stopTracking(reset: Bool) {
            displayLink?.invalidate()
            displayLink = nil
            startedAt = nil
            if reset {
                onReset()
                onProgress(0, false)
            }
        }
    }
}
