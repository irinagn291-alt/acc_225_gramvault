// Role: VIPER assembler for the root vault screen.

import UIKit

enum VaultModule {
    @MainActor
    static func assemble(
        catalog: VaultCatalogRepository,
        ledger: VaultLedgerRepository,
        aims: VaultAimRepository,
        wishes: VaultWishRepository,
        settings: VaultSettingsStore,
        factory: VaultModalFactory,
        showBriefing: Bool
    ) -> VaultViewController {
        let presenter = VaultPresenter()
        let interactor = VaultInteractor(
            catalog: catalog,
            ledger: ledger,
            aims: aims,
            wishes: wishes,
            settings: settings
        )
        let router = VaultRouter()
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        let view = VaultViewController(presenter: presenter)
        presenter.view = view
        router.host = view
        router.factory = factory
        presenter.shouldPresentBriefing = showBriefing
        return view
    }
}
