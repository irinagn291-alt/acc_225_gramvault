// Role: computed day aggregates. Never persisted.

import Foundation

struct VaultDayTotals: Sendable, Hashable {
    var kcal: Double
    var protein: Double
    var carbs: Double
    var fat: Double

    static let zero = VaultDayTotals(kcal: 0, protein: 0, carbs: 0, fat: 0)

    static func aggregate(entries: [VaultLogEntry], eatenOnly: Bool) -> VaultDayTotals {
        let relevant = entries.filter { eatenOnly ? $0.isEaten : true }
        var kcal = 0.0
        var protein = 0.0
        var carbs = 0.0
        var fat = 0.0
        for entry in relevant {
            let portion = entry.portion
            kcal += portion.kcal ?? 0
            protein += portion.protein ?? 0
            carbs += portion.carbs ?? 0
            fat += portion.fat ?? 0
        }
        return VaultDayTotals(kcal: kcal, protein: protein, carbs: carbs, fat: fat)
    }

    static func remaining(_ totals: VaultDayTotals, targets: VaultDailyTargets) -> VaultDayTotals {
        VaultDayTotals(
            kcal: targets.kcal - totals.kcal,
            protein: targets.protein - totals.protein,
            carbs: targets.carbs - totals.carbs,
            fat: targets.fat - totals.fat
        )
    }

    static func ratio(_ value: Double, target: Double) -> Double {
        guard target > 0 else { return 0 }
        return min(max(value / target, 0), 2)
    }
}
