// Role: VIPER assembler for AssignWizard.

import UIKit

enum AssignModule {
    @MainActor
    static func assemble(
        product: VaultProduct,
        catalog: VaultCatalogRepository,
        ledger: VaultLedgerRepository,
        wishes: VaultWishRepository,
        onClose: @escaping () -> Void
    ) -> UIViewController {
        let presenter = AssignPresenter(product: product)
        let interactor = AssignInteractor(wishes: wishes, ledger: ledger, catalog: catalog)
        let router = AssignRouter()
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        let view = AssignWizardViewController(presenter: presenter)
        presenter.view = view
        router.host = view
        router.onClose = onClose
        return view
    }
}
