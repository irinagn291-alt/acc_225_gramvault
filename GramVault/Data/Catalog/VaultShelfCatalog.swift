// Role: bundled local shelf used when search is empty, fails, or the vault is sealed.

import Foundation

enum VaultShelfCatalog {
    static let products: [VaultProduct] = [
        make(barcode: "3178530403022", name: "Vault Butter", brand: "Shelf", kcal: 717, protein: 0.9, carbs: 0.1, fat: 81.1, asset: "gvt_ProductPlaceholder"),
        make(barcode: "7394376616037", name: "Vault Oat Milk", brand: "Shelf", kcal: 45, protein: 1.0, carbs: 6.7, fat: 1.5, asset: "gvt_ProductPlaceholder"),
        make(barcode: "0041390001017", name: "Vault Soy Sauce", brand: "Shelf", kcal: 53, protein: 8.1, carbs: 4.9, fat: 0.6, asset: "gvt_ProductPlaceholder"),
        make(barcode: "5060335637000", name: "Vault Greek Yogurt", brand: "Shelf", kcal: 59, protein: 10.0, carbs: 3.6, fat: 0.4, asset: "gvt_ProductPlaceholder"),
        make(barcode: "8410054000129", name: "Vault Chickpeas", brand: "Shelf", kcal: 119, protein: 7.1, carbs: 16.2, fat: 2.6, asset: "gvt_ProductPlaceholder"),
        make(barcode: "8000070025431", name: "Vault Espresso", brand: "Shelf", kcal: 2, protein: 0.1, carbs: 0.0, fat: 0.0, asset: "gvt_ProductPlaceholder")
    ]

    static func matches(query: String) -> [VaultProduct] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return products }
        return products.filter {
            $0.name.lowercased().contains(needle)
                || $0.brand.lowercased().contains(needle)
                || $0.barcode.contains(needle)
        }
    }

    static func product(barcode: String) -> VaultProduct? {
        products.first { $0.barcode == barcode }
    }

    private static func make(
        barcode: String,
        name: String,
        brand: String,
        kcal: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        asset: String
    ) -> VaultProduct {
        VaultProduct(
            barcode: barcode,
            name: name,
            brand: brand,
            kcal100: kcal,
            protein100: protein,
            carbs100: carbs,
            fat100: fat,
            lastRefresh: Date(timeIntervalSince1970: 0),
            imageURL: nil,
            shelfAsset: asset,
            wishedAt: nil
        )
    }
}
