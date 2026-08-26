// Role: VIPER entity. Daily energy and macro aims. Never ship zeros.

import Foundation

struct VaultDailyTargets: Sendable, Hashable {
    var kcal: Double
    var protein: Double
    var carbs: Double
    var fat: Double

    static let factory = VaultDailyTargets(kcal: 2_200, protein: 140, carbs: 220, fat: 70)

    var isValid: Bool {
        kcal > 0 && protein >= 0 && carbs >= 0 && fat >= 0 && kcal <= 20_000
    }
}
