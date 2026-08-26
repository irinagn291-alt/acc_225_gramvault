import XCTest
@testable import GramVault

final class VaultPersistenceRoundTripTests: XCTestCase {
    func testWriteReloadRead() async throws {
        let settings = VaultSettingsStore(suiteName: "gvt.test.store.\(UUID().uuidString)")
        let store = VaultPersistentStore(inMemory: true, settings: settings)
        await store.open()
        let catalog = VaultCatalogRepository(store: store, client: VaultNetworkClient(), settings: settings)
        let ledger = VaultLedgerRepository(store: store)
        let product = VaultShelfCatalog.products[1]
        try await catalog.upsert(product)
        let day = VaultDayClock.dayKey(for: Date())
        let id = try await ledger.insert(product: product, grams: 80, slot: .vaultB, dayKey: day, eaten: true)
        let again = try await catalog.cached(barcode: product.barcode)
        XCTAssertEqual(again?.name, product.name)
        XCTAssertEqual(again?.kcal100, product.kcal100)
        let rows = try await ledger.entries(dayKey: day, eaten: true)
        XCTAssertEqual(rows.first?.id, id)
        XCTAssertEqual(rows.first?.grams, 80)
        XCTAssertEqual(rows.first?.slot, .vaultB)
    }
}
