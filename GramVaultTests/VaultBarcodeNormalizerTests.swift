import XCTest
@testable import GramVault

final class VaultBarcodeNormalizerTests: XCTestCase {
    func testEAN8() {
        XCTAssertEqual(VaultBarcodeNormalizer.candidates(from: "12345678"), ["12345678"])
    }

    func testEAN13() {
        XCTAssertEqual(VaultBarcodeNormalizer.candidates(from: "3178530403022"), ["3178530403022"])
    }

    func testUPCAPadding() {
        XCTAssertEqual(VaultBarcodeNormalizer.normalise("041390001017"), "0041390001017")
    }

    func testURLInput() {
        let raw = "https://world.openfoodfacts.org/product/5060335637000/yogurt"
        XCTAssertEqual(VaultBarcodeNormalizer.firstCandidate(from: raw), "5060335637000")
    }

    func testNoDigitRun() {
        XCTAssertTrue(VaultBarcodeNormalizer.candidates(from: "no-code").isEmpty)
    }
}
