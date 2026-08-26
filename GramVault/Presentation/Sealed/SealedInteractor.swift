// Role: VIPER interactor for sealed-vault status.

import Foundation

@MainActor
final class SealedInteractor: SealedInteractorInput {
    weak var output: SealedPresenterOutput?
    private let catalog: VaultCatalogRepository
    private let settings: VaultSettingsStore

    init(catalog: VaultCatalogRepository, settings: VaultSettingsStore) {
        self.catalog = catalog
        self.settings = settings
    }

    func load() {
        Task { [weak self] in
            let count = (try? await self?.catalog.cachedCount()) ?? 0
            self?.output?.interactorDidLoad(count: count, sealed: self?.settings.isSealed() ?? false)
        }
    }
}
