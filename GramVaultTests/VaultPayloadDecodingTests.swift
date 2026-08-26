import XCTest
@testable import GramVault

final class VaultPayloadDecodingTests: XCTestCase {
    func testStringAndMissingNutriments() throws {
        let json = """
        {
          "status": 1,
          "product": {
            "code": "12345678",
            "product_name": "Steel Oats",
            "brands": "Vault",
            "nutriments": {
              "energy-kcal_100g": "120",
              "proteins_100g": 4.5
            }
          }
        }
        """.data(using: .utf8) ?? Data()
        let payload = try JSONDecoder().decode(VaultProductLookupDTO.self, from: json)
        let product = payload.product?.mapped(fallbackBarcode: "12345678")
        XCTAssertEqual(product?.name, "Steel Oats")
        XCTAssertEqual(product?.kcal100, 120)
        XCTAssertEqual(product?.protein100, 4.5)
        XCTAssertNil(product?.carbs100)
        XCTAssertNil(product?.fat100)
    }

    func testStatusZeroIsNotMappedAsSuccess() throws {
        let json = """
        { "status": 0, "product": {} }
        """.data(using: .utf8) ?? Data()
        let payload = try JSONDecoder().decode(VaultProductLookupDTO.self, from: json)
        XCTAssertEqual(payload.status, 0)
    }
}
