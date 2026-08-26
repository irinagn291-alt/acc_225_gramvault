import XCTest
@testable import GramVault

final class VaultMacroUnknownTests: XCTestCase {
    func testUnknownMacrosStayNil() {
        let product = VaultProduct(
            barcode: "1",
            name: "Bare",
            brand: "",
            kcal100: 10,
            protein100: nil,
            carbs100: nil,
            fat100: nil,
            lastRefresh: Date(),
            imageURL: nil,
            shelfAsset: nil,
            wishedAt: nil
        )
        let portion = VaultPortionMaths.portion(grams: 100, perHundred: product)
        XCTAssertEqual(portion.kcal, 10)
        XCTAssertNil(portion.protein)
        XCTAssertNil(portion.carbs)
        XCTAssertNil(portion.fat)
        XCTAssertEqual(VaultFormatters.macroText(nil), "unknown")
    }
}
