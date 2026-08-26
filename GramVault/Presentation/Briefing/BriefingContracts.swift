// Role: suffix-based VIPER contracts for first-run briefing.

import Foundation

struct BriefingScreenModel: Sendable {
    var page: Int
    var image: String
    var title: String
    var copy: String
    var kcal: String
    var protein: String
    var carbs: String
    var fat: String
    var showsTargets: Bool
    var nextTitle: String
}

@MainActor
protocol BriefingViewProtocol: AnyObject {
    func render(_ model: BriefingScreenModel)
    func finish()
}

@MainActor
protocol BriefingInteractorInput: AnyObject {
    func complete(_ targets: VaultDailyTargets)
}

@MainActor
protocol BriefingPresenterOutput: AnyObject {
    func handleAppear()
    func handleNext()
    func handleSkip()
    func handleKcal(_ text: String)
    func handleProtein(_ text: String)
    func handleCarbs(_ text: String)
    func handleFat(_ text: String)
    func interactorDidComplete()
}

@MainActor
protocol BriefingRouterProtocol: AnyObject {
    func close()
}
