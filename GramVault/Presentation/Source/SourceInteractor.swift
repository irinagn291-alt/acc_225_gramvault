// Role: VIPER interactor for catalogue search and barcode resolve.

import Foundation

@MainActor
final class SourceInteractor: SourceInteractorInput {
    weak var output: SourcePresenterOutput?
    private let catalog: VaultCatalogRepository
    private var task: Task<Void, Never>?

    init(catalog: VaultCatalogRepository) {
        self.catalog = catalog
    }

    func search(_ query: String) {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let products = try await catalog.search(query: query)
                guard !Task.isCancelled else { return }
                output?.interactorDidSearch(products, query: query)
            } catch is CancellationError {
                return
            } catch let failure as VaultCatalogFailure where failure == .cancelled {
                return
            } catch let failure as VaultCatalogFailure {
                guard !Task.isCancelled else { return }
                output?.interactorDidFail(failure)
            } catch {
                guard !Task.isCancelled else { return }
                output?.interactorDidFail(.transport)
            }
        }
    }

    func resolve(_ raw: String) {
        task?.cancel()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                let product = try await catalog.resolve(raw: raw)
                guard !Task.isCancelled else { return }
                output?.interactorDidResolve(product)
            } catch is CancellationError {
                return
            } catch let failure as VaultCatalogFailure {
                guard !Task.isCancelled else { return }
                output?.interactorDidFail(failure)
            } catch {
                guard !Task.isCancelled else { return }
                output?.interactorDidFail(.transport)
            }
        }
    }
}
