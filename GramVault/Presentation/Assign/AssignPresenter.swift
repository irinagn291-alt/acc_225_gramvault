// Role: VIPER presenter for the assign wizard. No UIKit.

import Foundation

@MainActor
final class AssignPresenter: AssignPresenterOutput {
    weak var view: AssignViewProtocol?
    var interactor: AssignInteractorInput?
    var router: AssignRouterProtocol?

    private let product: VaultProduct
    private var page = 0
    private var grams: Double = 100
    private var gramsText = "100"
    private var slot: VaultSlot = .vaultA
    private var isFuture = false
    private var dayKey = VaultDayClock.dayKey(for: Date())
    private var wished = false
    private var busy = false
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    init(product: VaultProduct) {
        self.product = product
    }

    func handleAppear() {
        interactor?.loadWishState(barcode: product.barcode)
        publish()
    }

    func handleGrams(_ text: String) {
        gramsText = text
        if let parsed = VaultFormatters.parseGrams(text), VaultAssignRules.isGramsValid(parsed) {
            grams = parsed
        }
        publish()
    }

    func handleNext() {
        guard let parsed = VaultFormatters.parseGrams(gramsText), VaultAssignRules.isGramsValid(parsed) else {
            view?.announce(VaultCatalogFailure.invalidGrams.voice)
            return
        }
        grams = parsed
        page = 1
        publish()
    }

    func handleBack() {
        page = 0
        publish()
    }

    func handleWish() {
        guard !wished else { return }
        interactor?.addWish(product)
    }

    func handleSlot(_ slot: VaultSlot) {
        self.slot = slot
        publish()
    }

    func handleFuture(_ on: Bool) {
        isFuture = on
        if on {
            dayKey = VaultDayClock.shift(VaultDayClock.dayKey(for: Date()), days: 1)
            slot = VaultAssignRules.resolvedSlot(slot, isFuture: true)
        } else {
            dayKey = VaultDayClock.dayKey(for: Date())
        }
        publish()
    }

    func handleDate(_ date: Date) {
        dayKey = VaultDayClock.dayKey(for: date)
        isFuture = VaultDayClock.isFuture(dayKey)
        slot = VaultAssignRules.resolvedSlot(slot, isFuture: isFuture)
        publish()
    }

    func handleConfirm() {
        guard !busy else { return }
        guard VaultAssignRules.isGramsValid(grams) else {
            view?.announce(VaultCatalogFailure.invalidGrams.voice)
            return
        }
        busy = true
        publish()
        let resolved = VaultAssignRules.resolvedSlot(slot, isFuture: isFuture)
        interactor?.commit(product: product, grams: grams, slot: resolved, dayKey: dayKey, eaten: !isFuture)
    }

    func interactorDidWish(_ wished: Bool) {
        self.wished = wished
        publish()
    }

    func handleFinished() {
        router?.close()
    }

    func interactorDidCommit() {
        busy = false
        view?.closeAfterCommit()
    }

    func interactorDidFail(_ failure: VaultCatalogFailure) {
        busy = false
        publish()
        view?.announce(failure.voice)
    }

    private func publish() {
        let portion = VaultPortionMaths.portion(grams: grams, perHundred: product)
        view?.render(
            AssignScreenModel(
                page: page,
                name: product.name,
                brand: product.brand,
                energy100: VaultFormatters.energyText(product.kcal100),
                protein100: VaultFormatters.macroText(product.protein100),
                carbs100: VaultFormatters.macroText(product.carbs100),
                fat100: VaultFormatters.macroText(product.fat100),
                gramsText: gramsText,
                liveEnergy: VaultFormatters.energyText(portion.kcal),
                liveProtein: VaultFormatters.macroText(portion.protein),
                liveCarbs: VaultFormatters.macroText(portion.carbs),
                liveFat: VaultFormatters.macroText(portion.fat),
                wishTitle: wished ? "Already saved" : "Add to Wish",
                wishEnabled: !wished,
                slot: slot,
                isFuture: isFuture,
                dateLabel: dateFormatter.string(from: VaultDayClock.date(from: dayKey)),
                confirmEnabled: VaultAssignRules.isGramsValid(grams) && !busy,
                confirmBusy: busy,
                missingEnergy: !product.hasEnergy
            )
        )
    }
}
