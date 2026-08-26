// Role: VIPER presenter for briefing. No UIKit.

import Foundation

@MainActor
final class BriefingPresenter: BriefingPresenterOutput {
    weak var view: BriefingViewProtocol?
    var interactor: BriefingInteractorInput?
    var router: BriefingRouterProtocol?

    private var page = 0
    private var kcal = VaultDailyTargets.factory.kcal
    private var protein = VaultDailyTargets.factory.protein
    private var carbs = VaultDailyTargets.factory.carbs
    private var fat = VaultDailyTargets.factory.fat

    func handleAppear() { publish() }

    func handleNext() {
        if page < 3 {
            page += 1
            publish()
        } else {
            interactor?.complete(VaultDailyTargets(kcal: kcal, protein: protein, carbs: carbs, fat: fat))
        }
    }

    func handleSkip() {
        interactor?.complete(.factory)
    }

    func handleKcal(_ text: String) { kcal = VaultFormatters.parseGrams(text) ?? kcal }
    func handleProtein(_ text: String) { protein = VaultFormatters.parseGrams(text) ?? protein }
    func handleCarbs(_ text: String) { carbs = VaultFormatters.parseGrams(text) ?? carbs }
    func handleFat(_ text: String) { fat = VaultFormatters.parseGrams(text) ?? fat }

    func interactorDidComplete() {
        view?.finish()
        router?.close()
    }

    private func publish() {
        let pages: [(String, String, String)] = [
            ("gvt_Onboarding1", "Seal every gram", "GramVault keeps energy and macros in a local steel vault. No account. No ads."),
            ("gvt_Onboarding2", "Source and scan", "Search Open Food Facts or lock a barcode with the machined bracket."),
            ("gvt_Onboarding3", "Set the daily lock", "Choose energy, protein, carbs and fat. Skip writes a factory set."),
            ("gvt_Onboarding3", "Lock your targets", "Edit the factory set or keep it. Then the vault opens.")
        ]
        let current = pages[page]
        view?.render(
            BriefingScreenModel(
                page: page,
                image: current.0,
                title: current.1,
                copy: current.2,
                kcal: VaultFormatters.energyText(kcal),
                protein: VaultFormatters.macroText(protein),
                carbs: VaultFormatters.macroText(carbs),
                fat: VaultFormatters.macroText(fat),
                showsTargets: page == 3,
                nextTitle: page == 3 ? "Seal and open" : "Next"
            )
        )
    }
}
