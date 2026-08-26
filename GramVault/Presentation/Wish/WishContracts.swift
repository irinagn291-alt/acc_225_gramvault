// Role: suffix-based VIPER contracts for Wish.

import Foundation

struct WishScreenModel: Sendable {
    var rows: [WishRowModel]
    var empty: VaultEmptyModel?
}

struct WishRowModel: Sendable, Identifiable {
    var id: String
    var title: String
    var subtitle: String
}

@MainActor
protocol WishViewProtocol: AnyObject {
    func render(_ model: WishScreenModel)
}

@MainActor
protocol WishInteractorInput: AnyObject {
    func load()
    func remove(barcode: String)
    func product(barcode: String) async -> VaultProduct?
}

@MainActor
protocol WishPresenterOutput: AnyObject {
    func handleAppear()
    func handlePromote(_ barcode: String)
    func handleRemove(_ barcode: String)
    func handleEmpty()
    func interactorDidLoad(_ items: [VaultWishItem])
}

@MainActor
protocol WishRouterProtocol: AnyObject {
    func presentAssign(_ product: VaultProduct)
    func presentSource()
}
