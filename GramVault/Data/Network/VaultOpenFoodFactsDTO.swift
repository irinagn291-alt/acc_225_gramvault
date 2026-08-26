// Role: DTO types that mirror Open Food Facts JSON, then map to domain.

import Foundation

struct VaultFlexibleNumber: Decodable, Sendable {
    var value: Double?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            value = nil
        } else if let number = try? container.decode(Double.self) {
            value = number
        } else if let int = try? container.decode(Int.self) {
            value = Double(int)
        } else if let string = try? container.decode(String.self) {
            value = Double(string.replacingOccurrences(of: ",", with: "."))
        } else {
            value = nil
        }
    }
}

struct VaultNutrimentsDTO: Decodable, Sendable {
    var energyKcal100g: VaultFlexibleNumber?
    var energy100g: VaultFlexibleNumber?
    var proteins100g: VaultFlexibleNumber?
    var carbohydrates100g: VaultFlexibleNumber?
    var fat100g: VaultFlexibleNumber?

    enum CodingKeys: String, CodingKey {
        case energyKcal100g = "energy-kcal_100g"
        case energy100g = "energy_100g"
        case proteins100g = "proteins_100g"
        case carbohydrates100g = "carbohydrates_100g"
        case fat100g = "fat_100g"
    }
}

struct VaultProductDTO: Decodable, Sendable {
    var code: String?
    var productName: String?
    var genericName: String?
    var brands: String?
    var nutriments: VaultNutrimentsDTO?
    var imageFrontSmallURL: String?

    enum CodingKeys: String, CodingKey {
        case code
        case productName = "product_name"
        case genericName = "generic_name"
        case brands
        case nutriments
        case imageFrontSmallURL = "image_front_small_url"
    }

    func mapped(fallbackBarcode: String) -> VaultProduct? {
        let name = [productName, genericName, brands]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
        guard let name else { return nil }
        let trimmedCode = code?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let barcode = trimmedCode.isEmpty ? fallbackBarcode : trimmedCode
        guard !barcode.isEmpty else { return nil }
        let kcal = VaultPortionMaths.kilocaloriesPerHundred(
            energyKcal: nutriments?.energyKcal100g?.value,
            energyKj: nutriments?.energy100g?.value
        )
        return VaultProduct(
            barcode: barcode,
            name: name,
            brand: brands ?? "",
            kcal100: kcal,
            protein100: nutriments?.proteins100g?.value,
            carbs100: nutriments?.carbohydrates100g?.value,
            fat100: nutriments?.fat100g?.value,
            lastRefresh: Date(),
            imageURL: imageFrontSmallURL,
            shelfAsset: nil,
            wishedAt: nil
        )
    }
}

struct VaultSearchDTO: Decodable, Sendable {
    var products: [VaultProductDTO]?
}

struct VaultProductLookupDTO: Decodable, Sendable {
    var status: Int?
    var product: VaultProductDTO?
}
