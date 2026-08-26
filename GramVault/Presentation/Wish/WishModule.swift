// Role: VIPER assembler for Wish.

import UIKit

enum WishModule {
    @MainActor
    static func assemble(
        wishes: VaultWishRepository,
        catalog: VaultCatalogRepository,
        factory: VaultModalFactory,
        onClose: @escaping () -> Void
    ) -> UIViewController {
        let presenter = WishPresenter()
        let interactor = WishInteractor(wishes: wishes, catalog: catalog)
        let router = WishRouter()
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        let view = WishViewController(presenter: presenter)
        presenter.view = view
        router.host = view
        router.factory = factory
        router.onClose = onClose
        return view
    }
}
