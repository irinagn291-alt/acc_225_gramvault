// Role: VIPER view. Search and scan share one modal with a segmented switch.

import SnapKit
import UIKit

@MainActor
final class SourceModalViewController: UIViewController, SourceViewProtocol, VaultLiveScannerSink, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    private let presenter: SourcePresenterOutput
    private let scanner = VaultLiveScanner()
    private let segment = UISegmentedControl(items: ["Search", "Scan"])
    private let searchField = UITextField()
    private let table = UITableView(frame: .zero, style: .plain)
    private let empty = VaultEmptyPanel()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let previewHost = UIView()
    private let overlay = UIImageView(image: UIImage(named: "gvt_ScanOverlay"))
    private let lockLamp = UILabel()
    private let manual = UITextField()
    private let resolveButton = VaultSteelButton(title: "Resolve")
    private let cameraCopy = UILabel()
    private let settingsButton = VaultSteelButton(title: "Open Settings")
    private let chipHost = UIStackView()
    private var rows: [SourceRowModel] = []
    private var model = SourceScreenModel(
        pane: .search,
        query: "",
        state: .idle,
        rows: [],
        camera: .noDevice,
        locked: false,
        lockText: "SEEK",
        errorText: nil
    )
    private var backgroundObserver: NSObjectProtocol?
    private let thumbs = VaultThumbFetcher()

    init(presenter: SourcePresenterOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VaultPalette.color(.background)
        scanner.sink = self
        scanner.preview.frame = previewHost.bounds
        previewHost.layer.addSublayer(scanner.preview)
        build()
        presenter.handleAppear()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scanner.preview.frame = previewHost.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshCamera()
        let scanner = scanner
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            scanner.stop()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanner.stop()
        if let backgroundObserver {
            NotificationCenter.default.removeObserver(backgroundObserver)
            self.backgroundObserver = nil
        }
    }

    func render(_ model: SourceScreenModel) {
        self.model = model
        rows = model.rows
        segment.selectedSegmentIndex = model.pane == .search ? 0 : 1
        searchField.text = model.query
        let searching = model.pane == .search
        searchField.isHidden = !searching
        table.isHidden = !searching
        previewHost.isHidden = searching || model.camera != .live
        overlay.isHidden = searching || model.camera != .live
        lockLamp.isHidden = searching || model.camera != .live
        lockLamp.text = model.lockText
        lockLamp.backgroundColor = model.locked ? VaultPalette.color(.accent) : VaultPalette.color(.surface)
        lockLamp.textColor = model.locked ? VaultPalette.color(.background) : VaultPalette.color(.ink)
        cameraCopy.isHidden = searching || model.camera == .live
        settingsButton.isHidden = searching || (model.camera != .denied && model.camera != .restricted)
        chipHost.isHidden = searching || model.camera != .noDevice
        empty.isHidden = !(searching && (model.state == .empty || model.state == .idle || model.state == .transport) && model.rows.isEmpty)
        if model.state == .empty {
            empty.apply(image: "gvt_EmptySearch", title: "No rows", copy: model.errorText ?? "Try another term or the sealed shelf.", actionTitle: "Retry")
        } else if model.state == .transport {
            empty.apply(image: "gvt_EmptySearch", title: "Link failed", copy: model.errorText ?? VaultCatalogFailure.transport.voice, actionTitle: "Retry")
        } else if model.state == .idle {
            empty.apply(image: "gvt_EmptySearch", title: "Search the vault", copy: "Type a name. Sealed mode stays on the cached shelf.", actionTitle: "Scan instead")
        }
        cameraCopy.text = cameraMessage(model.camera)
        if model.state == .loading {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
        table.reloadData()
        if searching {
            scanner.stop()
        } else if model.camera == .live {
            scanner.start()
        }
    }

    func scannerDidRead(_ payload: String) {
        presenter.handleDecoded(payload)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        let row = rows[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = row.title
        content.secondaryText = "\(row.subtitle) · \(row.energy)"
        content.textProperties.font = VaultTypography.font(.headline)
        content.textProperties.color = VaultPalette.color(.ink)
        content.secondaryTextProperties.font = VaultTypography.font(.caption)
        content.secondaryTextProperties.color = VaultPalette.color(.muted)
        content.image = UIImage(named: row.shelfAsset ?? "gvt_ProductPlaceholder")
        content.imageProperties.maximumSize = CGSize(width: 44, height: 44)
        cell.contentConfiguration = content
        cell.backgroundColor = VaultPalette.color(.surface)
        cell.accessibilityLabel = "\(row.title), \(row.energy)"
        if row.imageURL != nil {
            let product = VaultProduct(
                barcode: row.barcode,
                name: row.title,
                brand: row.subtitle,
                kcal100: nil,
                protein100: nil,
                carbs100: nil,
                fat100: nil,
                lastRefresh: Date(),
                imageURL: row.imageURL,
                shelfAsset: row.shelfAsset,
                wishedAt: nil
            )
            Task { [thumbs] in
                let image = await thumbs.image(for: product)
                await MainActor.run {
                    guard tableView.cellForRow(at: indexPath) === cell else { return }
                    var updated = cell.defaultContentConfiguration()
                    updated.text = row.title
                    updated.secondaryText = "\(row.subtitle) · \(row.energy)"
                    updated.textProperties.font = VaultTypography.font(.headline)
                    updated.textProperties.color = VaultPalette.color(.ink)
                    updated.secondaryTextProperties.font = VaultTypography.font(.caption)
                    updated.secondaryTextProperties.color = VaultPalette.color(.muted)
                    updated.image = image
                    updated.imageProperties.maximumSize = CGSize(width: 44, height: 44)
                    cell.contentConfiguration = updated
                }
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.handleSelect(rows[indexPath.row].barcode)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == manual {
            presenter.handleManual(textField.text ?? "")
        }
        textField.resignFirstResponder()
        return true
    }

    private func build() {
        segment.selectedSegmentTintColor = VaultPalette.color(.accent)
        searchField.placeholder = "Search Open Food Facts"
        searchField.borderStyle = .roundedRect
        searchField.backgroundColor = VaultPalette.color(.surface)
        searchField.textColor = VaultPalette.color(.ink)
        searchField.font = VaultTypography.font(.body)
        searchField.adjustsFontForContentSizeCategory = true
        searchField.autocorrectionType = .no
        searchField.addAction(UIAction { [weak self] _ in
            self?.presenter.handleQuery(self?.searchField.text ?? "")
        }, for: .editingChanged)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "row")
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.rowHeight = 64
        table.keyboardDismissMode = .onDrag
        spinner.hidesWhenStopped = true
        overlay.contentMode = .scaleAspectFit
        overlay.isAccessibilityElement = false
        lockLamp.font = VaultTypography.font(.headline)
        lockLamp.textAlignment = .center
        lockLamp.isAccessibilityElement = true
        lockLamp.accessibilityLabel = "Scan lock"
        manual.placeholder = "Type or paste a barcode / URL"
        manual.borderStyle = .roundedRect
        manual.keyboardType = .numbersAndPunctuation
        manual.delegate = self
        manual.font = VaultTypography.font(.body)
        manual.adjustsFontForContentSizeCategory = true
        manual.backgroundColor = VaultPalette.color(.surface)
        manual.textColor = VaultPalette.color(.ink)
        cameraCopy.font = VaultTypography.font(.body)
        cameraCopy.textColor = VaultPalette.color(.ink)
        cameraCopy.numberOfLines = 0
        cameraCopy.adjustsFontForContentSizeCategory = true
        chipHost.axis = .vertical
        chipHost.spacing = VaultMetrics.space(1)
        for product in VaultShelfCatalog.products {
            let chip = VaultSteelButton(title: product.name)
            chip.accessibilityLabel = "Sample \(product.name)"
            chip.addAction(UIAction { [weak self] _ in
                self?.presenter.handleManual(product.barcode)
            }, for: .touchUpInside)
            chipHost.addArrangedSubview(chip)
        }
        empty.action.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            if self.model.state == .idle {
                self.presenter.handlePane(.scan)
            } else {
                self.presenter.handleRetry()
            }
        }, for: .touchUpInside)
        segment.addAction(UIAction { [weak self] _ in
            self?.presenter.handlePane(self?.segment.selectedSegmentIndex == 0 ? .search : .scan)
        }, for: .valueChanged)
        resolveButton.addAction(UIAction { [weak self] _ in
            self?.presenter.handleManual(self?.manual.text ?? "")
        }, for: .touchUpInside)
        settingsButton.addAction(UIAction { [weak self] _ in
            self?.presenter.handleOpenSettings()
        }, for: .touchUpInside)
        [segment, searchField, table, empty, spinner, previewHost, overlay, lockLamp, cameraCopy, settingsButton, chipHost, manual, resolveButton].forEach { view.addSubview($0) }
        segment.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
            make.height.equalTo(VaultMetrics.tap)
        }
        searchField.snp.makeConstraints { make in
            make.top.equalTo(segment.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
            make.height.equalTo(VaultMetrics.tap)
        }
        table.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        empty.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(3))
        }
        spinner.snp.makeConstraints { $0.center.equalToSuperview() }
        previewHost.snp.makeConstraints { make in
            make.top.equalTo(segment.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(previewHost.snp.width)
        }
        overlay.snp.makeConstraints { $0.edges.equalTo(previewHost) }
        lockLamp.snp.makeConstraints { make in
            make.top.equalTo(previewHost.snp.bottom).offset(VaultMetrics.space(1))
            make.centerX.equalToSuperview()
            make.width.equalTo(96)
            make.height.equalTo(VaultMetrics.tap)
        }
        cameraCopy.snp.makeConstraints { make in
            make.top.equalTo(segment.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
        }
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(cameraCopy.snp.bottom).offset(VaultMetrics.space(2))
            make.centerX.equalToSuperview()
        }
        chipHost.snp.makeConstraints { make in
            make.top.equalTo(cameraCopy.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
        }
        resolveButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(VaultMetrics.space(2))
            make.trailing.equalToSuperview().inset(VaultMetrics.space(2))
        }
        manual.snp.makeConstraints { make in
            make.centerY.equalTo(resolveButton)
            make.leading.equalToSuperview().inset(VaultMetrics.space(2))
            make.trailing.equalTo(resolveButton.snp.leading).offset(-VaultMetrics.space(1))
            make.height.equalTo(VaultMetrics.tap)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    private func refreshCamera() {
        if !scanner.hasDevice {
            presenter.applyCameraIfPossible(.noDevice)
            return
        }
        switch scanner.authorization() {
        case .authorized:
            presenter.applyCameraIfPossible(.live)
        case .denied:
            presenter.applyCameraIfPossible(.denied)
        case .restricted:
            presenter.applyCameraIfPossible(.restricted)
        case .notDetermined:
            presenter.applyCameraIfPossible(.ask)
            Task { [weak self] in
                let granted = await self?.scanner.requestAccess() ?? false
                self?.presenter.applyCameraIfPossible(granted ? .live : .denied)
            }
        @unknown default:
            presenter.applyCameraIfPossible(.denied)
        }
    }

    private func cameraMessage(_ state: SourceCameraState) -> String {
        switch state {
        case .live: ""
        case .noDevice: "No capture device. Use a sample chip or type a barcode."
        case .denied: VaultCatalogFailure.cameraDenied.voice
        case .restricted: VaultCatalogFailure.cameraRestricted.voice
        case .ask: "GramVault will ask to read barcodes into your vault."
        }
    }
}

private extension SourcePresenterOutput {
    func applyCameraIfPossible(_ state: SourceCameraState) {
        (self as? SourcePresenter)?.applyCamera(state)
    }
}
