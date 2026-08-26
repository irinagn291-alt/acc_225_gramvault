// Role: portion conversion. Stored values keep full precision.

import Foundation

struct VaultPortion: Sendable, Hashable {
    var kcal: Double?
    var protein: Double?
    var carbs: Double?
    var fat: Double?
}

enum VaultPortionMaths {
    static let kilojoulePerKilocalorie = 4.184

    static func kilocaloriesPerHundred(energyKcal: Double?, energyKj: Double?) -> Double? {
        if let energyKcal {
            return energyKcal
        }
        if let energyKj {
            return energyKj / kilojoulePerKilocalorie
        }
        return nil
    }

    static func scale(_ perHundred: Double?, grams: Double) -> Double? {
        guard let perHundred else { return nil }
        return perHundred * grams / 100
    }

    static func portion(grams: Double, perHundred product: VaultProduct) -> VaultPortion {
        VaultPortion(
            kcal: scale(product.kcal100, grams: grams),
            protein: scale(product.protein100, grams: grams),
            carbs: scale(product.carbs100, grams: grams),
            fat: scale(product.fat100, grams: grams)
        )
    }
}
