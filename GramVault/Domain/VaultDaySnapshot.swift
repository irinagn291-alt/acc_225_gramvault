// Role: assembled day state passed from interactor to presenter.

import Foundation

struct VaultDaySnapshot: Sendable {
    var dayKey: Int
    var targets: VaultDailyTargets
    var eaten: [VaultLogEntry]
    var planned: [VaultLogEntry]
    var wishes: [VaultWishItem]
    var isSealed: Bool
    var cachedProductCount: Int
    var recoveredStore: Bool
    var highlightedEntryID: UUID?

    var totals: VaultDayTotals {
        VaultDayTotals.aggregate(entries: eaten, eatenOnly: true)
    }

    func entries(in slot: VaultSlot, eatenOnly: Bool) -> [VaultLogEntry] {
        let source = eatenOnly ? eaten : planned
        return source.filter { $0.slot == slot }
    }
}
