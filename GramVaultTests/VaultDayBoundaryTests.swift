import XCTest
@testable import GramVault

final class VaultDayBoundaryTests: XCTestCase {
    func testSpringForwardStillUsesStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/New_York") ?? .current
        var parts = DateComponents(year: 2024, month: 3, day: 10, hour: 1, minute: 30)
        let before = calendar.date(from: parts) ?? Date()
        parts.hour = 3
        parts.minute = 30
        let after = calendar.date(from: parts) ?? Date()
        let first = VaultDayClock.dayKey(for: before, calendar: calendar)
        let second = VaultDayClock.dayKey(for: after, calendar: calendar)
        XCTAssertEqual(first, second)
        let next = VaultDayClock.nextDayKey(after: first, calendar: calendar)
        XCTAssertGreaterThan(next, first)
        XCTAssertLessThan(next - first, 90_000)
    }
}
