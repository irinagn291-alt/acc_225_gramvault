// Role: VIPER interactor for wish and ledger writes.

import Foundation

@MainActor
final class AssignInteractor: AssignInteractorInput {
    weak var output: AssignPresenterOutput?
    private let wishes: VaultWishRepository
    private let ledger: VaultLedgerRepository
    private let catalog: VaultCatalogRepository

    init(wishes: VaultWishRepository, ledger: VaultLedgerRepository, catalog: VaultCatalogRepository) {
        self.wishes = wishes
        self.ledger = ledger
        self.catalog = catalog
    }

    func loadWishState(barcode: String) {
        Task { [weak self] in
            let wished = (try? await self?.wishes.contains(barcode: barcode)) ?? false
            self?.output?.interactorDidWish(wished)
        }
    }

    func addWish(_ product: VaultProduct) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await catalog.upsert(product)
                _ = try await wishes.add(product)
                output?.interactorDidWish(true)
            } catch {
                output?.interactorDidFail(.store)
            }
        }
    }

    func commit(product: VaultProduct, grams: Double, slot: VaultSlot, dayKey: Int, eaten: Bool) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await catalog.upsert(product)
                _ = try await ledger.insert(product: product, grams: grams, slot: slot, dayKey: dayKey, eaten: eaten)
                output?.interactorDidCommit()
            } catch {
                output?.interactorDidFail(.store)
            }
        }
    }
}
