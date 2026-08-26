// Role: VIPER presenter for the twist screen. No UIKit.

import Foundation

@MainActor
final class SealedPresenter: SealedPresenterOutput {
    weak var view: SealedViewProtocol?
    var interactor: SealedInteractorInput?
    var router: SealedRouterProtocol?

    func handleAppear() {
        interactor?.load()
    }

    func interactorDidLoad(count: Int, sealed: Bool) {
        view?.render(
            SealedScreenModel(
                title: sealed ? "VAULT SEALED" : "VAULT OPEN",
                copy: "Every resolved product stays in the local vault. Flip Sealed on the main chamber to cut the network. Search and scan then use the cached shelf only.",
                cached: "Sealed catalogue: \(count) products"
            )
        )
    }
}
