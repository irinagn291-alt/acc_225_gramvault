// Role: shared easing and duration; honour Reduce Motion.

import UIKit

@MainActor
enum VaultMotion {
    static var duration: TimeInterval {
        UIAccessibility.isReduceMotionEnabled ? 0.12 : 0.28
    }

    static var curve: UIView.AnimationOptions {
        UIAccessibility.isReduceMotionEnabled ? .curveLinear : .curveEaseInOut
    }

    static func animate(_ changes: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: [curve, .beginFromCurrentState], animations: changes, completion: completion)
    }
}
