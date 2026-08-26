// Role: VIPER entity. Cached catalogue row seen by UI and interactors.

import Foundation

struct VaultProduct: Sendable, Hashable, Identifiable {
    var barcode: String
    var name: String
    var brand: String
    var kcal100: Double?
    var protein100: Double?
    var carbs100: Double?
    var fat100: Double?
    var lastRefresh: Date
    var imageURL: String?
    var shelfAsset: String?
    var wishedAt: Date?

    var id: String { barcode }

    var isWished: Bool { wishedAt != nil }

    var hasEnergy: Bool { kcal100 != nil }
}
