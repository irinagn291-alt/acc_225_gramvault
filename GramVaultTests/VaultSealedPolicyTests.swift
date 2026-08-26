import XCTest
@testable import GramVault

final class VaultSealedPolicyTests: XCTestCase {
    func testSealedBlocksNetwork() {
        let sealed = VaultSealedPolicy(isSealed: true)
        XCTAssertFalse(sealed.allowsNetwork)
        XCTAssertFalse(sealed.shouldQueryRemote(query: "oat", cachedCount: 0))
        XCTAssertFalse(sealed.shouldResolveRemote(barcode: "1", cached: nil))
    }

    func testOpenAllowsNetwork() {
        let open = VaultSealedPolicy(isSealed: false)
        XCTAssertTrue(open.allowsNetwork)
        XCTAssertTrue(open.shouldQueryRemote(query: "oat", cachedCount: 0))
        XCTAssertTrue(open.shouldResolveRemote(barcode: "1", cached: nil))
    }
}
