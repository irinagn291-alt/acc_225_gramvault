// Role: VIPER interactor for the wish list.

import Foundation

@MainActor
final class WishInteractor: WishInteractorInput {
    weak var output: WishPresenterOutput?
    private let wishes: VaultWishRepository
    private let catalog: VaultCatalogRepository

    init(wishes: VaultWishRepository, catalog: VaultCatalogRepository) {
        self.wishes = wishes
        self.catalog = catalog
    }

    func load() {
        Task { [weak self] in
            let items = (try? await self?.wishes.all()) ?? []
            self?.output?.interactorDidLoad(items)
        }
    }

    func remove(barcode: String) {
        Task { [weak self] in
            try? await self?.wishes.remove(barcode: barcode)
            self?.load()
        }
    }

    func product(barcode: String) async -> VaultProduct? {
        try? await catalog.cached(barcode: barcode)
    }
}
