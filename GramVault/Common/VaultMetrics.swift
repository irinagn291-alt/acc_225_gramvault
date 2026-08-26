// Role: spacing, radius and tap-target constants used by every view.

import CoreGraphics

enum VaultMetrics {
    static let unit: CGFloat = 8
    static let radius: CGFloat = 0
    static let tap: CGFloat = 44

    static func space(_ multiples: Int) -> CGFloat {
        unit * CGFloat(multiples)
    }
}
