// Role: VIPER assembler for briefing.

import UIKit

enum BriefingModule {
    @MainActor
    static func assemble(aims: VaultAimRepository, settings: VaultSettingsStore, onDone: @escaping () -> Void) -> UIViewController {
        let presenter = BriefingPresenter()
        let interactor = BriefingInteractor(aims: aims, settings: settings)
        let router = BriefingRouter()
        presenter.interactor = interactor
        presenter.router = router
        interactor.output = presenter
        let view = BriefingViewController(presenter: presenter)
        presenter.view = view
        router.host = view
        router.onDone = onDone
        return view
    }
}
