// Role: suffix-based VIPER contracts for Targets (goals).

import Foundation

struct TargetsScreenModel: Sendable {
    var kcal: String
    var protein: String
    var carbs: String
    var fat: String
    var saveEnabled: Bool
}

@MainActor
protocol TargetsViewProtocol: AnyObject {
    func render(_ model: TargetsScreenModel)
    func announce(_ message: String)
}

@MainActor
protocol TargetsInteractorInput: AnyObject {
    func load()
    func save(_ targets: VaultDailyTargets)
    func resetAll()
    func reopenBriefing()
}

@MainActor
protocol TargetsPresenterOutput: AnyObject {
    func handleAppear()
    func handleKcal(_ text: String)
    func handleProtein(_ text: String)
    func handleCarbs(_ text: String)
    func handleFat(_ text: String)
    func handleSave()
    func handleReset()
    func handleBriefing()
    func handleContact()
    func interactorDidLoad(_ targets: VaultDailyTargets)
    func interactorDidSave()
    func interactorDidReset()
    func interactorDidFail(_ failure: VaultCatalogFailure)
}

@MainActor
protocol TargetsRouterProtocol: AnyObject {
    func presentBriefing()
    func openContact()
    func confirmReset(onConfirm: @escaping () -> Void)
}
