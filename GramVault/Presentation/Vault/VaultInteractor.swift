// Role: VIPER interactor. Owns vault business rules. No UIKit.

import Foundation

@MainActor
final class VaultInteractor: VaultInteractorInput {
    weak var output: VaultPresenterOutput?

    private let catalog: VaultCatalogRepository
    private let ledger: VaultLedgerRepository
    private let aims: VaultAimRepository
    private let wishes: VaultWishRepository
    private let settings: VaultSettingsStore
    private var loadTask: Task<Void, Never>?
    private var dayKey = VaultDayClock.dayKey(for: Date())

    init(
        catalog: VaultCatalogRepository,
        ledger: VaultLedgerRepository,
        aims: VaultAimRepository,
        wishes: VaultWishRepository,
        settings: VaultSettingsStore
    ) {
        self.catalog = catalog
        self.ledger = ledger
        self.aims = aims
        self.wishes = wishes
        self.settings = settings
    }

    func load(dayKey: Int) {
        self.dayKey = dayKey
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await catalog.seedShelfIfNeeded()
                let targets = try await aims.load()
                let eaten = try await ledger.entries(dayKey: dayKey, eaten: true)
                let plannedToday = try await ledger.entries(dayKey: dayKey, eaten: false)
                let horizon = try await ledger.plannedHorizon(from: dayKey, days: 14)
                let wishItems = try await wishes.all()
                let count = try await catalog.cachedCount()
                let snapshot = VaultDaySnapshot(
                    dayKey: dayKey,
                    targets: targets,
                    eaten: eaten,
                    planned: plannedToday + horizon,
                    wishes: wishItems,
                    isSealed: settings.isSealed(),
                    cachedProductCount: count,
                    recoveredStore: settings.consumeRecoveredFlag(),
                    highlightedEntryID: nil
                )
                guard !Task.isCancelled else { return }
                output?.interactorDidLoad(snapshot)
            } catch {
                guard !Task.isCancelled else { return }
                output?.interactorDidFail(.store)
            }
        }
    }

    func toggleSealed(_ on: Bool) {
        settings.setSealed(on)
        load(dayKey: dayKey)
    }

    func deleteEntry(id: UUID) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await ledger.delete(id: id)
                load(dayKey: dayKey)
            } catch {
                output?.interactorDidFail(.store)
            }
        }
    }

    func eatPlanned(id: UUID) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await ledger.convertToEaten(id: id, dayKey: VaultDayClock.dayKey(for: Date()))
                load(dayKey: VaultDayClock.dayKey(for: Date()))
            } catch {
                output?.interactorDidFail(.store)
            }
        }
    }
}
