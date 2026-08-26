import XCTest
@testable import GramVault

final class VaultPortionMathsTests: XCTestCase {
    func testKilocaloriePath() {
        let kcal100 = VaultPortionMaths.kilocaloriesPerHundred(energyKcal: 200, energyKj: 900)
        XCTAssertEqual(kcal100, 200)
        XCTAssertEqual(VaultPortionMaths.scale(kcal100, grams: 50), 100)
    }

    func testKilojouleFallback() {
        let kcal100 = VaultPortionMaths.kilocaloriesPerHundred(energyKcal: nil, energyKj: 418.4)
        XCTAssertEqual(kcal100 ?? 0, 100, accuracy: 0.0001)
    }

    func testMissingEnergyStaysUnknown() {
        XCTAssertNil(VaultPortionMaths.kilocaloriesPerHundred(energyKcal: nil, energyKj: nil))
        XCTAssertNil(VaultPortionMaths.scale(nil, grams: 80))
    }
}
