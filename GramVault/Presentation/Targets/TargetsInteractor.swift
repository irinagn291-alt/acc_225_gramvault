// Role: VIPER interactor for targets, reset, and briefing flag.

import Foundation

@MainActor
final class TargetsInteractor: TargetsInteractorInput {
    weak var output: TargetsPresenterOutput?
    private let aims: VaultAimRepository
    private let store: VaultPersistentStore
    private let settings: VaultSettingsStore
    private let catalog: VaultCatalogRepository

    init(
        aims: VaultAimRepository,
        store: VaultPersistentStore,
        settings: VaultSettingsStore,
        catalog: VaultCatalogRepository
    ) {
        self.aims = aims
        self.store = store
        self.settings = settings
        self.catalog = catalog
    }

    func load() {
        Task { [weak self] in
            do {
                let targets = try await self?.aims.load()
                if let targets {
                    self?.output?.interactorDidLoad(targets)
                }
            } catch {
                self?.output?.interactorDidFail(.store)
            }
        }
    }

    func save(_ targets: VaultDailyTargets) {
        Task { [weak self] in
            do {
                try await self?.aims.save(targets)
                self?.output?.interactorDidSave()
            } catch {
                self?.output?.interactorDidFail(.store)
            }
        }
    }

    func resetAll() {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await store.resetAllData()
                settings.resetSessionFlags()
                try await catalog.seedShelfIfNeeded()
                try await aims.save(VaultDailyTargets.factory)
                output?.interactorDidReset()
            } catch {
                output?.interactorDidFail(.store)
            }
        }
    }

    func reopenBriefing() {
        settings.clearBriefing()
        output?.interactorDidReset()
    }
}
