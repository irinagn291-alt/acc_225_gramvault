import XCTest
@testable import GramVault

final class VaultDayTotalsTests: XCTestCase {
    func testAggregationAcrossSlots() {
        let product = VaultProduct(
            barcode: "x",
            name: "X",
            brand: "",
            kcal100: 100,
            protein100: 10,
            carbs100: 20,
            fat100: 5,
            lastRefresh: Date(),
            imageURL: nil,
            shelfAsset: nil,
            wishedAt: nil
        )
        let day = 1_700_000_000
        let entries = VaultSlot.allCases.enumerated().map { index, slot in
            VaultLogEntry(
                id: UUID(),
                product: product,
                grams: 100,
                slot: slot,
                dayKey: day,
                isEaten: true,
                createdAt: Date()
            )
        }
        let totals = VaultDayTotals.aggregate(entries: entries, eatenOnly: true)
        XCTAssertEqual(totals.kcal, 400)
        XCTAssertEqual(totals.protein, 40)
        XCTAssertEqual(totals.carbs, 80)
        XCTAssertEqual(totals.fat, 20)
    }
}
