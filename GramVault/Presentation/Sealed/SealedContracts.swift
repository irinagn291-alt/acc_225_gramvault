// Role: suffix-based VIPER contracts for the offline-first twist screen.

import Foundation

struct SealedScreenModel: Sendable {
    var title: String
    var copy: String
    var cached: String
}

@MainActor
protocol SealedViewProtocol: AnyObject {
    func render(_ model: SealedScreenModel)
}

@MainActor
protocol SealedInteractorInput: AnyObject {
    func load()
}

@MainActor
protocol SealedPresenterOutput: AnyObject {
    func handleAppear()
    func interactorDidLoad(count: Int, sealed: Bool)
}

@MainActor
protocol SealedRouterProtocol: AnyObject {}
