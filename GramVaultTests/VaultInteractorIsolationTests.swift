import XCTest
@testable import GramVault

final class VaultInteractorIsolationTests: XCTestCase {
    func testLooseChangeRemapsToVaultCOnFutureDate() {
        XCTAssertEqual(VaultAssignRules.resolvedSlot(.looseChange, isFuture: true), .vaultC)
        XCTAssertEqual(VaultAssignRules.resolvedSlot(.looseChange, isFuture: false), .looseChange)
        XCTAssertEqual(VaultAssignRules.resolvedSlot(.vaultA, isFuture: true), .vaultA)
    }

    func testIllegalGramsRejected() {
        XCTAssertFalse(VaultAssignRules.isGramsValid(0))
        XCTAssertFalse(VaultAssignRules.isGramsValid(-4))
        XCTAssertFalse(VaultAssignRules.isGramsValid(20_000))
        XCTAssertTrue(VaultAssignRules.isGramsValid(35))
    }
}
