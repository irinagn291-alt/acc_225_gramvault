// Role: VIPER entity. A sealed or planned portion.

import Foundation

struct VaultLogEntry: Sendable, Hashable, Identifiable {
    var id: UUID
    var product: VaultProduct
    var grams: Double
    var slot: VaultSlot
    var dayKey: Int
    var isEaten: Bool
    var createdAt: Date

    var portion: VaultPortion {
        VaultPortionMaths.portion(grams: grams, perHundred: product)
    }
}
