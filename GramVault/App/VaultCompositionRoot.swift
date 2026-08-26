// Role: composition root. Wires repositories and VIPER assemblers.

import UIKit

@MainActor
final class VaultCompositionRoot: VaultModalFactory {
    let settings = VaultSettingsStore()
    let store: VaultPersistentStore
    let client = VaultNetworkClient()
    let catalog: VaultCatalogRepository
    let ledger: VaultLedgerRepository
    let aims: VaultAimRepository
    let wishes: VaultWishRepository

    init(inMemory: Bool = false) {
        store = VaultPersistentStore(inMemory: inMemory, settings: settings)
        catalog = VaultCatalogRepository(store: store, client: client, settings: settings)
        ledger = VaultLedgerRepository(store: store)
        aims = VaultAimRepository(store: store)
        wishes = VaultWishRepository(store: store)
    }

    func prepare() async {
        if let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        await store.open()
        try? await catalog.seedShelfIfNeeded()
        await VaultDemoSeeder.seedIfNeeded(settings: settings, catalog: catalog, ledger: ledger, aims: aims)
    }

    func makeVault() -> UIViewController {
        VaultModule.assemble(
            catalog: catalog,
            ledger: ledger,
            aims: aims,
            wishes: wishes,
            settings: settings,
            factory: self,
            showBriefing: !settings.briefingComplete()
        )
    }

    func makeSource(onClose: @escaping () -> Void) -> UIViewController {
        SourceModule.assemble(catalog: catalog, factory: self, onClose: onClose)
    }

    func makeWish(onClose: @escaping () -> Void) -> UIViewController {
        WishModule.assemble(wishes: wishes, catalog: catalog, factory: self, onClose: onClose)
    }

    func makeTargets(onClose: @escaping () -> Void) -> UIViewController {
        TargetsModule.assemble(aims: aims, store: store, settings: settings, catalog: catalog, factory: self)
    }

    func makeSealed() -> UIViewController {
        SealedModule.assemble(catalog: catalog, settings: settings)
    }

    func makeBriefing(onDone: @escaping () -> Void) -> UIViewController {
        BriefingModule.assemble(aims: aims, settings: settings, onDone: onDone)
    }

    func makeAssign(product: VaultProduct, onClose: @escaping () -> Void) -> UIViewController {
        AssignModule.assemble(product: product, catalog: catalog, ledger: ledger, wishes: wishes, onClose: onClose)
    }
}
