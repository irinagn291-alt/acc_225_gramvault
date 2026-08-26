import XCTest
@testable import GramVault

final class VaultWishUniquenessTests: XCTestCase {
    func testDuplicateAddUpdatesExistingRow() async throws {
        let settings = VaultSettingsStore(suiteName: "gvt.test.wish.\(UUID().uuidString)")
        let store = VaultPersistentStore(inMemory: true, settings: settings)
        await store.open()
        let wishes = VaultWishRepository(store: store)
        let product = VaultShelfCatalog.products[0]
        let first = try await wishes.add(product)
        let second = try await wishes.add(product)
        XCTAssertEqual(first.product.barcode, second.product.barcode)
        XCTAssertEqual(first.added.timeIntervalSince1970, second.added.timeIntervalSince1970, accuracy: 0.01)
        let all = try await wishes.all()
        XCTAssertEqual(all.count, 1)
    }
}
