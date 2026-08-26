// Role: VIPER presenter. Formats snapshot. Does not import UIKit.

import Foundation

@MainActor
final class VaultPresenter: VaultPresenterOutput {
    weak var view: VaultViewProtocol?
    var interactor: VaultInteractorInput?
    var router: VaultRouterProtocol?

    var shouldPresentBriefing = false
    private var reviewApplied = false
    private var snapshot: VaultDaySnapshot?
    private var pane: VaultPane = .chamber
    private var dayKey = VaultDayClock.dayKey(for: Date())
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    func handleAppear() {
        if shouldPresentBriefing {
            shouldPresentBriefing = false
            router?.presentBriefing()
        }
        interactor?.load(dayKey: dayKey)
        guard reviewApplied == false else { return }
        reviewApplied = true
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-ReviewScreen"), index + 1 < args.count else { return }
        switch args[index + 1] {
        case "log": handleSelectPane(.ledger)
        case "goals": handleSelectTargets()
        default: break
        }
    }

    func handleSelectSource() {
        router?.presentSource()
    }

    func handleSelectWish() {
        router?.presentWish()
    }

    func handleSelectTargets() {
        router?.presentTargets()
    }

    func handleSelectSealedInfo() {
        router?.presentSealed()
    }

    func handleToggleSealed(_ on: Bool) {
        interactor?.toggleSealed(on)
    }

    func handleSelectPane(_ pane: VaultPane) {
        self.pane = pane
        if let snapshot {
            view?.render(model(from: snapshot))
        }
    }

    func handleShiftDay(_ delta: Int) {
        dayKey = VaultDayClock.shift(dayKey, days: delta)
        interactor?.load(dayKey: dayKey)
    }

    func handleDeleteEntry(_ id: String) {
        router?.confirmDelete(id) { [weak self] in
            guard let uuid = UUID(uuidString: id) else { return }
            self?.interactor?.deleteEntry(id: uuid)
        }
    }

    func handleEatPlanned(_ id: String) {
        guard let uuid = UUID(uuidString: id) else { return }
        interactor?.eatPlanned(id: uuid)
    }

    func handleEmptyAction() {
        switch pane {
        case .chamber, .ledger:
            router?.presentSource()
        case .horizon:
            router?.presentSource()
        }
    }

    func handleDidCloseModal() {
        interactor?.load(dayKey: dayKey)
    }

    func interactorDidLoad(_ snapshot: VaultDaySnapshot) {
        self.snapshot = snapshot
        dayKey = snapshot.dayKey
        if snapshot.recoveredStore {
            view?.announce(VaultCatalogFailure.recoveredStore.voice)
        }
        view?.render(model(from: snapshot))
    }

    func interactorDidFail(_ failure: VaultCatalogFailure) {
        view?.announce(failure.voice)
    }

    private func model(from snapshot: VaultDaySnapshot) -> VaultScreenModel {
        let totals = snapshot.totals
        let targets = snapshot.targets
        let macros = [
            VaultMacroChipModel(
                title: "Protein",
                value: "\(VaultFormatters.macroText(totals.protein)) / \(VaultFormatters.macroText(targets.protein))",
                asset: "gvt_MacroProtein",
                filled: totals.protein > targets.protein
            ),
            VaultMacroChipModel(
                title: "Carbs",
                value: "\(VaultFormatters.macroText(totals.carbs)) / \(VaultFormatters.macroText(targets.carbs))",
                asset: "gvt_MacroCarbs",
                filled: totals.carbs > targets.carbs
            ),
            VaultMacroChipModel(
                title: "Fat",
                value: "\(VaultFormatters.macroText(totals.fat)) / \(VaultFormatters.macroText(targets.fat))",
                asset: "gvt_MacroFat",
                filled: totals.fat > targets.fat
            )
        ]
        let rows: [VaultRowModel]
        let empty: VaultEmptyModel?
        switch pane {
        case .chamber:
            rows = snapshot.eaten.map { row(from: $0, canDelete: true, canEat: false) }
            empty = rows.isEmpty
                ? VaultEmptyModel(
                    image: "gvt_EmptyLog",
                    title: "Chamber is empty",
                    copy: "Seal a product from Source to start today's log.",
                    action: "Open Source"
                )
                : nil
        case .ledger:
            rows = snapshot.eaten.map { row(from: $0, canDelete: true, canEat: false) }
            empty = rows.isEmpty
                ? VaultEmptyModel(
                    image: "gvt_EmptyLog",
                    title: "No seals this day",
                    copy: "Switch days or add a product from Source.",
                    action: "Open Source"
                )
                : nil
        case .horizon:
            rows = snapshot.planned.map { row(from: $0, canDelete: true, canEat: true) }
            empty = rows.isEmpty
                ? VaultEmptyModel(
                    image: "gvt_EmptyPlan",
                    title: "Horizon is clear",
                    copy: "Plan ahead up to 14 days. Loose Change stays eaten-only.",
                    action: "Plan from Source"
                )
                : nil
        }
        return VaultScreenModel(
            title: "GRAM VAULT",
            dayLabel: dateFormatter.string(from: VaultDayClock.date(from: snapshot.dayKey)),
            energyValue: VaultFormatters.energyText(totals.kcal),
            energyTarget: VaultFormatters.energyText(targets.kcal),
            energyProgress: VaultDayTotals.ratio(totals.kcal, target: targets.kcal),
            energyExceeded: totals.kcal > targets.kcal,
            macros: macros,
            isSealed: snapshot.isSealed,
            sealedCaption: snapshot.isSealed ? "Seal on — network off" : "Seal off — network allowed",
            cachedCountText: "Cached \(snapshot.cachedProductCount)",
            pane: pane,
            rows: rows,
            empty: empty,
            highlightID: snapshot.highlightedEntryID?.uuidString
        )
    }

    private func row(from entry: VaultLogEntry, canDelete: Bool, canEat: Bool) -> VaultRowModel {
        VaultRowModel(
            id: entry.id.uuidString,
            title: entry.product.name,
            subtitle: "\(entry.slot.title) · \(VaultFormatters.macroText(entry.grams)) g",
            energy: "\(VaultFormatters.energyText(entry.portion.kcal)) kcal",
            slotTitle: entry.slot.title,
            slotAsset: entry.slot.assetName,
            canDelete: canDelete,
            canEat: canEat
        )
    }
}
