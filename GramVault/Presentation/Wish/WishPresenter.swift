// Role: VIPER presenter for Wish. No UIKit.

import Foundation

@MainActor
final class WishPresenter: WishPresenterOutput {
    weak var view: WishViewProtocol?
    var interactor: WishInteractorInput?
    var router: WishRouterProtocol?
    private var items: [VaultWishItem] = []

    func handleAppear() {
        interactor?.load()
    }

    func handlePromote(_ barcode: String) {
        Task { [weak self] in
            guard let product = await self?.interactor?.product(barcode: barcode) else { return }
            self?.router?.presentAssign(product)
        }
    }

    func handleRemove(_ barcode: String) {
        interactor?.remove(barcode: barcode)
    }

    func handleEmpty() {
        router?.presentSource()
    }

    func interactorDidLoad(_ items: [VaultWishItem]) {
        self.items = items
        let rows = items.map {
            WishRowModel(id: $0.product.barcode, title: $0.product.name, subtitle: $0.product.barcode)
        }
        let empty = rows.isEmpty
            ? VaultEmptyModel(
                image: "gvt_EmptyWish",
                title: "Wish shelf is empty",
                copy: "Save a product from Source to buy later.",
                action: "Open Source"
            )
            : nil
        view?.render(WishScreenModel(rows: rows, empty: empty))
    }
}
