// Role: suffix-based VIPER contracts for Source (search + scan).

import Foundation

enum SourcePane: String, Sendable {
    case search
    case scan
}

enum SourceLoadState: String, Sendable {
    case idle
    case loading
    case results
    case empty
    case transport
}

struct SourceScreenModel: Sendable {
    var pane: SourcePane
    var query: String
    var state: SourceLoadState
    var rows: [SourceRowModel]
    var camera: SourceCameraState
    var locked: Bool
    var lockText: String
    var errorText: String?
}

struct SourceRowModel: Sendable, Identifiable {
    var id: String
    var title: String
    var subtitle: String
    var energy: String
    var barcode: String
    var imageURL: String?
    var shelfAsset: String?
}

enum SourceCameraState: String, Sendable {
    case live
    case noDevice
    case denied
    case restricted
    case ask
}

@MainActor
protocol SourceViewProtocol: AnyObject {
    func render(_ model: SourceScreenModel)
}

@MainActor
protocol SourceInteractorInput: AnyObject {
    func search(_ query: String)
    func resolve(_ raw: String)
}

@MainActor
protocol SourcePresenterOutput: AnyObject {
    func handleAppear()
    func handlePane(_ pane: SourcePane)
    func handleQuery(_ text: String)
    func handleRetry()
    func handleSelect(_ barcode: String)
    func handleManual(_ raw: String)
    func handleDecoded(_ raw: String)
    func handleOpenSettings()
    func interactorDidSearch(_ products: [VaultProduct], query: String)
    func interactorDidResolve(_ product: VaultProduct)
    func interactorDidFail(_ failure: VaultCatalogFailure)
}

@MainActor
protocol SourceRouterProtocol: AnyObject {
    func presentAssign(_ product: VaultProduct)
    func openSettings()
}
