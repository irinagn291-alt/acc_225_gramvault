// Role: VIPER assembler for Source.

import UIKit

enum SourceModule {
    @MainActor
    static func assemble(
        catalog: VaultCatalogRepository,
        factory: VaultModalFactory,
        onClose: @escaping () -> Void
    ) -> UIViewController {
        let presenter = SourcePresenter()
        let interactor = SourceInteractor(catalog: catalog)
        let router = SourceRouter()
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        let view = SourceModalViewController(presenter: presenter)
        presenter.view = view
        router.host = view
        router.factory = factory
        router.onClose = onClose
        return view
    }
}
