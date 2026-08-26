// Role: simulator-only demo day, gated by gvt.demo.v1.

import Foundation

enum VaultDemoSeeder {
    static func seedIfNeeded(
        settings: VaultSettingsStore,
        catalog: VaultCatalogRepository,
        ledger: VaultLedgerRepository,
        aims: VaultAimRepository
    ) async {
        #if targetEnvironment(simulator)
        guard settings.consumeDemoSeedIfNeeded() else { return }
        do {
            try await catalog.seedShelfIfNeeded()
            try await aims.save(VaultDailyTargets.factory)
            let day = VaultDayClock.dayKey(for: Date())
            let shelf = VaultShelfCatalog.products
            if let butter = shelf.first(where: { $0.barcode == "3178530403022" }) {
                try await catalog.upsert(butter)
                _ = try await ledger.insert(product: butter, grams: 12, slot: .vaultA, dayKey: day, eaten: true)
            }
            if let yogurt = shelf.first(where: { $0.barcode == "5060335637000" }) {
                try await catalog.upsert(yogurt)
                _ = try await ledger.insert(product: yogurt, grams: 200, slot: .vaultB, dayKey: day, eaten: true)
            }
            if let espresso = shelf.first(where: { $0.barcode == "8000070025431" }) {
                try await catalog.upsert(espresso)
                _ = try await ledger.insert(product: espresso, grams: 30, slot: .looseChange, dayKey: day, eaten: true)
            }
            if let chickpeas = shelf.first(where: { $0.barcode == "8410054000129" }) {
                try await catalog.upsert(chickpeas)
                let tomorrow = VaultDayClock.shift(day, days: 1)
                _ = try await ledger.insert(product: chickpeas, grams: 150, slot: .vaultC, dayKey: tomorrow, eaten: false)
            }
            settings.markBriefingComplete()
        } catch {
            return
        }
        #endif
    }
}
