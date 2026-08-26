// Role: suffix-based VIPER contracts for the root vault screen.

import Foundation

enum VaultPane: String, Sendable {
    case chamber
    case ledger
    case horizon
}

struct VaultScreenModel: Sendable {
    var title: String
    var dayLabel: String
    var energyValue: String
    var energyTarget: String
    var energyProgress: Double
    var energyExceeded: Bool
    var macros: [VaultMacroChipModel]
    var isSealed: Bool
    var sealedCaption: String
    var cachedCountText: String
    var pane: VaultPane
    var rows: [VaultRowModel]
    var empty: VaultEmptyModel?
    var highlightID: String?
}

struct VaultRowModel: Sendable, Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var energy: String
    var slotTitle: String
    var slotAsset: String
    var canDelete: Bool
    var canEat: Bool
}

struct VaultEmptyModel: Sendable {
    var image: String
    var title: String
    var copy: String
    var action: String
}

@MainActor
protocol VaultViewProtocol: AnyObject {
    func render(_ model: VaultScreenModel)
    func announce(_ message: String)
}

@MainActor
protocol VaultInteractorInput: AnyObject {
    func load(dayKey: Int)
    func toggleSealed(_ on: Bool)
    func deleteEntry(id: UUID)
    func eatPlanned(id: UUID)
}

@MainActor
protocol VaultPresenterOutput: AnyObject {
    func handleAppear()
    func handleSelectSource()
    func handleSelectWish()
    func handleSelectTargets()
    func handleSelectSealedInfo()
    func handleToggleSealed(_ on: Bool)
    func handleSelectPane(_ pane: VaultPane)
    func handleShiftDay(_ delta: Int)
    func handleDeleteEntry(_ id: String)
    func handleEatPlanned(_ id: String)
    func handleEmptyAction()
    func handleDidCloseModal()
    func interactorDidLoad(_ snapshot: VaultDaySnapshot)
    func interactorDidFail(_ failure: VaultCatalogFailure)
}

@MainActor
protocol VaultRouterProtocol: AnyObject {
    func presentSource()
    func presentWish()
    func presentTargets()
    func presentSealed()
    func presentBriefing()
    func confirmDelete(_ id: String, onConfirm: @escaping () -> Void)
}
