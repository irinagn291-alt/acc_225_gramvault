// Role: VIPER assembler for Targets.

import UIKit

enum TargetsModule {
    @MainActor
    static func assemble(
        aims: VaultAimRepository,
        store: VaultPersistentStore,
        settings: VaultSettingsStore,
        catalog: VaultCatalogRepository,
        factory: VaultModalFactory
    ) -> UIViewController {
        let presenter = TargetsPresenter()
        let interactor = TargetsInteractor(aims: aims, store: store, settings: settings, catalog: catalog)
        let router = TargetsRouter()
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        let view = TargetsViewController(presenter: presenter)
        presenter.view = view
        router.host = view
        router.factory = factory
        return view
    }
}
