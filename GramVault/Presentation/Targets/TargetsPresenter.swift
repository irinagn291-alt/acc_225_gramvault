// Role: VIPER presenter for Targets. No UIKit.

import Foundation

@MainActor
final class TargetsPresenter: TargetsPresenterOutput {
    weak var view: TargetsViewProtocol?
    var interactor: TargetsInteractorInput?
    var router: TargetsRouterProtocol?

    private var kcal = VaultDailyTargets.factory.kcal
    private var protein = VaultDailyTargets.factory.protein
    private var carbs = VaultDailyTargets.factory.carbs
    private var fat = VaultDailyTargets.factory.fat

    func handleAppear() {
        interactor?.load()
    }

    func handleKcal(_ text: String) { kcal = VaultFormatters.parseGrams(text) ?? 0; publish() }
    func handleProtein(_ text: String) { protein = VaultFormatters.parseGrams(text) ?? 0; publish() }
    func handleCarbs(_ text: String) { carbs = VaultFormatters.parseGrams(text) ?? 0; publish() }
    func handleFat(_ text: String) { fat = VaultFormatters.parseGrams(text) ?? 0; publish() }

    func handleSave() {
        let targets = VaultDailyTargets(kcal: kcal, protein: protein, carbs: carbs, fat: fat)
        guard targets.isValid else {
            view?.announce("Targets need a positive energy value.")
            return
        }
        interactor?.save(targets)
    }

    func handleReset() {
        router?.confirmReset { [weak self] in
            self?.interactor?.resetAll()
        }
    }

    func handleBriefing() {
        interactor?.reopenBriefing()
        router?.presentBriefing()
    }

    func handleContact() {
        router?.openContact()
    }

    func interactorDidLoad(_ targets: VaultDailyTargets) {
        kcal = targets.kcal
        protein = targets.protein
        carbs = targets.carbs
        fat = targets.fat
        publish()
    }

    func interactorDidSave() {
        publish()
        view?.announce("Targets sealed.")
    }

    func interactorDidReset() {
        interactor?.load()
    }

    func interactorDidFail(_ failure: VaultCatalogFailure) {
        view?.announce(failure.voice)
    }

    private func publish() {
        let targets = VaultDailyTargets(kcal: kcal, protein: protein, carbs: carbs, fat: fat)
        view?.render(
            TargetsScreenModel(
                kcal: VaultFormatters.energyText(kcal),
                protein: VaultFormatters.macroText(protein),
                carbs: VaultFormatters.macroText(carbs),
                fat: VaultFormatters.macroText(fat),
                saveEnabled: targets.isValid
            )
        )
    }
}
