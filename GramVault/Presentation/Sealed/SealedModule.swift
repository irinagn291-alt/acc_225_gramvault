// Role: VIPER assembler for the sealed twist screen.

import UIKit

enum SealedModule {
    @MainActor
    static func assemble(catalog: VaultCatalogRepository, settings: VaultSettingsStore) -> UIViewController {
        let presenter = SealedPresenter()
        let interactor = SealedInteractor(catalog: catalog, settings: settings)
        let router = SealedRouter()
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        let view = SealedViewController(presenter: presenter)
        presenter.view = view
        router.host = view
        return view
    }
}
