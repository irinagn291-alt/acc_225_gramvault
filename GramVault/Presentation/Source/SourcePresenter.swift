// Role: VIPER presenter for Source. No UIKit import.

import Foundation

@MainActor
final class SourcePresenter: SourcePresenterOutput {
    weak var view: SourceViewProtocol?
    var interactor: SourceInteractorInput?
    var router: SourceRouterProtocol?

    private var pane: SourcePane = .search
    private var query = ""
    private var state: SourceLoadState = .idle
    private var rows: [SourceRowModel] = []
    private var camera: SourceCameraState = .noDevice
    private var locked = false
    private var lastPayload = ""
    private var errorText: String?
    private var products: [VaultProduct] = []
    private var searchTask: Task<Void, Never>?
    private var spinnerTask: Task<Void, Never>?

    func handleAppear() {
        publish()
    }

    func handlePane(_ pane: SourcePane) {
        self.pane = pane
        publish()
    }

    func handleQuery(_ text: String) {
        query = text
        searchTask?.cancel()
        spinnerTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            state = .idle
            rows = []
            errorText = nil
            publish()
            return
        }
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            self?.beginLoadingThenSearch(trimmed)
        }
    }

    func handleRetry() {
        if pane == .search {
            handleQuery(query)
        }
    }

    func handleSelect(_ barcode: String) {
        if let product = products.first(where: { $0.barcode == barcode }) {
            router?.presentAssign(product)
        } else {
            armSpinner()
            interactor?.resolve(barcode)
        }
    }

    func handleManual(_ raw: String) {
        armSpinner()
        interactor?.resolve(raw)
    }

    func handleDecoded(_ raw: String) {
        if raw == lastPayload { return }
        lastPayload = raw
        locked = true
        publish()
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_700_000_000)
            self?.locked = false
            self?.lastPayload = ""
            self?.publish()
        }
        armSpinner()
        interactor?.resolve(raw)
    }

    func handleOpenSettings() {
        router?.openSettings()
    }

    func interactorDidSearch(_ products: [VaultProduct], query: String) {
        spinnerTask?.cancel()
        self.products = products
        rows = products.map(Self.row)
        state = products.isEmpty ? .empty : .results
        errorText = products.isEmpty ? "No catalogue rows. The shelf is empty for this query." : nil
        self.query = query
        publish()
    }

    func interactorDidResolve(_ product: VaultProduct) {
        spinnerTask?.cancel()
        state = .results
        errorText = product.hasEnergy ? nil : VaultCatalogFailure.missingEnergy.voice
        products = [product]
        rows = [Self.row(product)]
        publish()
        router?.presentAssign(product)
    }

    func interactorDidFail(_ failure: VaultCatalogFailure) {
        spinnerTask?.cancel()
        state = .transport
        errorText = failure.voice
        if pane == .search {
            let shelf = VaultShelfCatalog.matches(query: query)
            products = shelf
            rows = shelf.map(Self.row)
            if !shelf.isEmpty {
                state = .results
            }
        }
        publish()
    }

    func applyCamera(_ camera: SourceCameraState) {
        self.camera = camera
        publish()
    }

    private func beginLoadingThenSearch(_ query: String) {
        armSpinner()
        interactor?.search(query)
    }

    private func armSpinner() {
        spinnerTask?.cancel()
        spinnerTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            self?.state = .loading
            self?.publish()
        }
    }

    private func publish() {
        view?.render(
            SourceScreenModel(
                pane: pane,
                query: query,
                state: state,
                rows: rows,
                camera: camera,
                locked: locked,
                lockText: locked ? "LOCK" : "SEEK",
                errorText: errorText
            )
        )
    }

    private static func row(_ product: VaultProduct) -> SourceRowModel {
        SourceRowModel(
            id: product.barcode,
            title: product.name,
            subtitle: product.brand.isEmpty ? product.barcode : product.brand,
            energy: product.hasEnergy ? "\(VaultFormatters.energyText(product.kcal100)) kcal/100 g" : "unknown energy",
            barcode: product.barcode,
            imageURL: product.imageURL,
            shelfAsset: product.shelfAsset
        )
    }
}
