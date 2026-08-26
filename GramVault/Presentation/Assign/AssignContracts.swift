// Role: suffix-based VIPER contracts for the two-page assign wizard.

import Foundation

struct AssignScreenModel: Sendable {
    var page: Int
    var name: String
    var brand: String
    var energy100: String
    var protein100: String
    var carbs100: String
    var fat100: String
    var gramsText: String
    var liveEnergy: String
    var liveProtein: String
    var liveCarbs: String
    var liveFat: String
    var wishTitle: String
    var wishEnabled: Bool
    var slot: VaultSlot
    var isFuture: Bool
    var dateLabel: String
    var confirmEnabled: Bool
    var confirmBusy: Bool
    var missingEnergy: Bool
}

@MainActor
protocol AssignViewProtocol: AnyObject {
    func render(_ model: AssignScreenModel)
    func closeAfterCommit()
    func announce(_ message: String)
}

@MainActor
protocol AssignInteractorInput: AnyObject {
    func loadWishState(barcode: String)
    func addWish(_ product: VaultProduct)
    func commit(product: VaultProduct, grams: Double, slot: VaultSlot, dayKey: Int, eaten: Bool)
}

@MainActor
protocol AssignPresenterOutput: AnyObject {
    func handleAppear()
    func handleGrams(_ text: String)
    func handleNext()
    func handleBack()
    func handleWish()
    func handleSlot(_ slot: VaultSlot)
    func handleFuture(_ on: Bool)
    func handleDate(_ date: Date)
    func handleConfirm()
    func handleFinished()
    func interactorDidWish(_ wished: Bool)
    func interactorDidCommit()
    func interactorDidFail(_ failure: VaultCatalogFailure)
}

@MainActor
protocol AssignRouterProtocol: AnyObject {
    func close()
}
