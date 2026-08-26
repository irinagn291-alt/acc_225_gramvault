// Role: one haptic on a successful commit. Never used for navigation.

import UIKit

@MainActor
enum VaultHaptics {
    static func commit() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
