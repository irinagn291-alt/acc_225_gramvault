// Role: VIPER view. Programmatic UIKit root vault. SnapKit on this composite.

import SnapKit
import UIKit

@MainActor
final class VaultViewController: UIViewController, VaultViewProtocol {
    let presenter: VaultPresenterOutput

    private let scroll = UIScrollView()
    private let content = UIView()
    private let texture = UIImageView(image: UIImage(named: "gvt_Texture"))
    private let header = UIImageView(image: UIImage(named: "gvt_HeaderDecor"))
    private let titleLabel = UILabel()
    private let dayLabel = UILabel()
    private let prevDay = UIButton(type: .system)
    private let nextDay = UIButton(type: .system)
    private let energyValue = UILabel()
    private let energyTarget = UILabel()
    private let energyBar = UIProgressView(progressViewStyle: .bar)
    private let macros = VaultMacroStrip()
    private let sealedSwitch = UISwitch()
    private let sealedCaption = UILabel()
    private let sealedInfo = UIButton(type: .system)
    private let cacheLabel = UILabel()
    private let pane = UISegmentedControl(items: ["Chamber", "Ledger", "Horizon"])
    private let stack = UIStackView()
    private let empty = VaultEmptyPanel()
    private let sourceButton = VaultSteelButton(title: "Source")
    private let wishButton = VaultSteelButton(title: "Wish")
    private let targetsButton = VaultSteelButton(title: "Targets")
    private let actions = UIStackView()
    private var lastEnergy = ""
    private var dayObserver: NSObjectProtocol?

    init(presenter: VaultPresenterOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VaultPalette.color(.background)
        configureHierarchy()
        configureActions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.handleAppear()
    }

    func render(_ model: VaultScreenModel) {
        titleLabel.text = model.title
        dayLabel.text = model.dayLabel
        energyTarget.text = "/ \(model.energyTarget) kcal"
        energyBar.setProgress(Float(min(model.energyProgress, 1)), animated: false)
        energyBar.progressTintColor = model.energyExceeded ? VaultPalette.color(.accent) : VaultPalette.color(.ink)
        macros.render(model.macros)
        sealedSwitch.isOn = model.isSealed
        sealedCaption.text = model.sealedCaption
        cacheLabel.text = model.cachedCountText
        pane.selectedSegmentIndex = [VaultPane.chamber, .ledger, .horizon].firstIndex(of: model.pane) ?? 0
        if lastEnergy != model.energyValue {
            lastEnergy = model.energyValue
            VaultMotion.animate { self.energyValue.alpha = 0 }
            energyValue.text = model.energyValue
            VaultMotion.animate { self.energyValue.alpha = 1 }
        } else {
            energyValue.text = model.energyValue
        }
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        empty.isHidden = model.empty == nil
        if let emptyModel = model.empty {
            empty.apply(image: emptyModel.image, title: emptyModel.title, copy: emptyModel.copy, actionTitle: emptyModel.action)
            stack.addArrangedSubview(empty)
        } else {
            for (index, row) in model.rows.enumerated() {
                let cell = VaultEntryCell(model: row)
                cell.onDelete = { [weak self] in self?.presenter.handleDeleteEntry(row.id) }
                cell.onEat = { [weak self] in self?.presenter.handleEatPlanned(row.id) }
                if row.id == model.highlightID {
                    cell.layer.borderColor = VaultPalette.color(.accent).cgColor
                    cell.layer.borderWidth = 2
                }
                stack.addArrangedSubview(cell)
                if !UIAccessibility.isReduceMotionEnabled {
                    cell.alpha = 0
                    UIView.animate(withDuration: VaultMotion.duration, delay: 0.03 * Double(index), options: VaultMotion.curve) {
                        cell.alpha = 1
                    }
                }
            }
        }
    }

    func announce(_ message: String) {
        let alert = UIAlertController(title: "Vault", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func configureHierarchy() {
        texture.contentMode = .scaleAspectFill
        texture.alpha = 0.12
        texture.isAccessibilityElement = false
        header.contentMode = .scaleAspectFill
        header.clipsToBounds = true
        header.isAccessibilityElement = false
        titleLabel.font = VaultTypography.font(.title)
        titleLabel.textColor = VaultPalette.color(.ink)
        titleLabel.adjustsFontForContentSizeCategory = true
        dayLabel.font = VaultTypography.font(.caption)
        dayLabel.textColor = VaultPalette.color(.muted)
        dayLabel.adjustsFontForContentSizeCategory = true
        energyValue.font = VaultTypography.font(.display)
        energyValue.textColor = VaultPalette.color(.accent)
        energyValue.adjustsFontForContentSizeCategory = true
        energyValue.adjustsFontSizeToFitWidth = true
        energyTarget.font = VaultTypography.font(.numeral)
        energyTarget.textColor = VaultPalette.color(.muted)
        energyTarget.adjustsFontForContentSizeCategory = true
        energyBar.trackTintColor = VaultPalette.color(.surface)
        sealedCaption.font = VaultTypography.font(.caption)
        sealedCaption.textColor = VaultPalette.color(.ink)
        sealedCaption.adjustsFontForContentSizeCategory = true
        cacheLabel.font = VaultTypography.font(.caption)
        cacheLabel.textColor = VaultPalette.color(.muted)
        cacheLabel.adjustsFontForContentSizeCategory = true
        pane.selectedSegmentTintColor = VaultPalette.color(.accent)
        stack.axis = .vertical
        stack.spacing = VaultMetrics.space(1)
        actions.axis = .horizontal
        actions.spacing = VaultMetrics.space(1)
        actions.distribution = .fillEqually
        actions.addArrangedSubview(sourceButton)
        actions.addArrangedSubview(wishButton)
        actions.addArrangedSubview(targetsButton)
        styleIconButton(prevDay, symbol: "chevron.left", label: "Previous day")
        styleIconButton(nextDay, symbol: "chevron.right", label: "Next day")
        sealedInfo.setTitle("About seal", for: .normal)
        sealedInfo.accessibilityLabel = "What sealed vault means"
        sealedInfo.tintColor = VaultPalette.color(.accent)
        sealedSwitch.accessibilityLabel = "Seal network"
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        view.addSubview(texture)
        view.addSubview(scroll)
        scroll.addSubview(content)
        [header, titleLabel, prevDay, dayLabel, nextDay, energyValue, energyTarget, energyBar, macros, sealedSwitch, sealedCaption, sealedInfo, cacheLabel, pane, stack, actions].forEach { content.addSubview($0) }
        texture.snp.makeConstraints { $0.edges.equalToSuperview() }
        scroll.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scroll)
        }
        header.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(88)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
        }
        prevDay.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.equalToSuperview().inset(VaultMetrics.space(2))
            make.width.height.equalTo(VaultMetrics.tap)
        }
        nextDay.snp.makeConstraints { make in
            make.centerY.equalTo(prevDay)
            make.trailing.equalToSuperview().inset(VaultMetrics.space(2))
            make.width.height.equalTo(VaultMetrics.tap)
        }
        dayLabel.snp.makeConstraints { make in
            make.centerY.equalTo(prevDay)
            make.leading.equalTo(prevDay.snp.trailing).offset(VaultMetrics.space(1))
            make.trailing.equalTo(nextDay.snp.leading).offset(-VaultMetrics.space(1))
        }
        energyValue.snp.makeConstraints { make in
            make.top.equalTo(prevDay.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.equalToSuperview().inset(VaultMetrics.space(2))
        }
        energyTarget.snp.makeConstraints { make in
            make.lastBaseline.equalTo(energyValue)
            make.leading.equalTo(energyValue.snp.trailing).offset(VaultMetrics.space(1))
            make.trailing.lessThanOrEqualToSuperview().inset(VaultMetrics.space(2))
        }
        energyBar.snp.makeConstraints { make in
            make.top.equalTo(energyValue.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
            make.height.equalTo(8)
        }
        macros.snp.makeConstraints { make in
            make.top.equalTo(energyBar.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
        }
        sealedSwitch.snp.makeConstraints { make in
            make.top.equalTo(macros.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.equalToSuperview().inset(VaultMetrics.space(2))
        }
        sealedCaption.snp.makeConstraints { make in
            make.centerY.equalTo(sealedSwitch)
            make.leading.equalTo(sealedSwitch.snp.trailing).offset(VaultMetrics.space(1))
        }
        sealedInfo.snp.makeConstraints { make in
            make.centerY.equalTo(sealedSwitch)
            make.trailing.equalToSuperview().inset(VaultMetrics.space(2))
            make.height.greaterThanOrEqualTo(VaultMetrics.tap)
        }
        cacheLabel.snp.makeConstraints { make in
            make.top.equalTo(sealedSwitch.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
        }
        pane.snp.makeConstraints { make in
            make.top.equalTo(cacheLabel.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
            make.height.equalTo(VaultMetrics.tap)
        }
        stack.snp.makeConstraints { make in
            make.top.equalTo(pane.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
        }
        actions.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
            make.bottom.equalToSuperview().inset(VaultMetrics.space(2))
        }
        energyValue.setContentCompressionResistancePriority(.required, for: .horizontal)
        dayLabel.lineBreakMode = .byTruncatingTail
    }

    private func configureActions() {
        prevDay.addAction(UIAction { [weak self] _ in self?.presenter.handleShiftDay(-1) }, for: .touchUpInside)
        nextDay.addAction(UIAction { [weak self] _ in self?.presenter.handleShiftDay(1) }, for: .touchUpInside)
        sealedSwitch.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.presenter.handleToggleSealed(self.sealedSwitch.isOn)
        }, for: .valueChanged)
        sealedInfo.addAction(UIAction { [weak self] _ in self?.presenter.handleSelectSealedInfo() }, for: .touchUpInside)
        pane.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let panes: [VaultPane] = [.chamber, .ledger, .horizon]
            self.presenter.handleSelectPane(panes[self.pane.selectedSegmentIndex])
        }, for: .valueChanged)
        sourceButton.addAction(UIAction { [weak self] _ in self?.presenter.handleSelectSource() }, for: .touchUpInside)
        wishButton.addAction(UIAction { [weak self] _ in self?.presenter.handleSelectWish() }, for: .touchUpInside)
        targetsButton.addAction(UIAction { [weak self] _ in self?.presenter.handleSelectTargets() }, for: .touchUpInside)
        empty.action.addAction(UIAction { [weak self] _ in self?.presenter.handleEmptyAction() }, for: .touchUpInside)
        dayObserver = NotificationCenter.default.addObserver(forName: .gvtDayMayHaveChanged, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.presenter.handleAppear()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(dayShifted), name: UIApplication.significantTimeChangeNotification, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditingNow))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func endEditingNow() {
        view.endEditing(true)
    }

    @objc private func dayShifted() {
        presenter.handleAppear()
    }

    private func styleIconButton(_ button: UIButton, symbol: String, label: String) {
        button.setImage(UIImage(systemName: symbol), for: .normal)
        button.tintColor = VaultPalette.color(.ink)
        button.accessibilityLabel = label
    }
}

final class VaultEntryCell: UIView {
    var onDelete: (() -> Void)?
    var onEat: (() -> Void)?

    init(model: VaultRowModel) {
        super.init(frame: .zero)
        backgroundColor = VaultPalette.color(.surface)
        layer.borderWidth = 1
        layer.borderColor = VaultPalette.color(.muted).cgColor
        let icon = UIImageView(image: UIImage(named: model.slotAsset))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.isAccessibilityElement = false
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.text = model.title
        name.font = VaultTypography.font(.headline)
        name.textColor = VaultPalette.color(.ink)
        name.lineBreakMode = .byTruncatingTail
        name.adjustsFontForContentSizeCategory = true
        let sub = UILabel()
        sub.translatesAutoresizingMaskIntoConstraints = false
        sub.text = model.subtitle
        sub.font = VaultTypography.font(.caption)
        sub.textColor = VaultPalette.color(.muted)
        sub.adjustsFontForContentSizeCategory = true
        let energy = UILabel()
        energy.translatesAutoresizingMaskIntoConstraints = false
        energy.text = model.energy
        energy.font = VaultTypography.font(.numeral)
        energy.textColor = VaultPalette.color(.accent)
        energy.setContentCompressionResistancePriority(.required, for: .horizontal)
        energy.adjustsFontForContentSizeCategory = true
        let delete = UIButton(type: .system)
        delete.translatesAutoresizingMaskIntoConstraints = false
        delete.setTitle("Delete", for: .normal)
        delete.accessibilityLabel = "Delete \(model.title)"
        delete.tintColor = VaultPalette.color(.ink)
        delete.isHidden = !model.canDelete
        delete.addAction(UIAction { [weak self] _ in self?.onDelete?() }, for: .touchUpInside)
        let eat = UIButton(type: .system)
        eat.translatesAutoresizingMaskIntoConstraints = false
        eat.setTitle("Eat", for: .normal)
        eat.accessibilityLabel = "Convert \(model.title) to eaten"
        eat.tintColor = VaultPalette.color(.accent)
        eat.isHidden = !model.canEat
        eat.addAction(UIAction { [weak self] _ in self?.onEat?() }, for: .touchUpInside)
        [icon, name, sub, energy, delete, eat].forEach { addSubview($0) }
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VaultMetrics.space(1)),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 32),
            icon.heightAnchor.constraint(equalToConstant: 32),
            name.topAnchor.constraint(equalTo: topAnchor, constant: VaultMetrics.space(1)),
            name.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: VaultMetrics.space(1)),
            name.trailingAnchor.constraint(lessThanOrEqualTo: energy.leadingAnchor, constant: -VaultMetrics.space(1)),
            sub.topAnchor.constraint(equalTo: name.bottomAnchor),
            sub.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            sub.trailingAnchor.constraint(lessThanOrEqualTo: energy.leadingAnchor, constant: -VaultMetrics.space(1)),
            energy.centerYAnchor.constraint(equalTo: centerYAnchor),
            energy.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VaultMetrics.space(1)),
            delete.topAnchor.constraint(equalTo: sub.bottomAnchor, constant: VaultMetrics.space(1)),
            delete.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            delete.heightAnchor.constraint(greaterThanOrEqualToConstant: VaultMetrics.tap),
            eat.centerYAnchor.constraint(equalTo: delete.centerYAnchor),
            eat.leadingAnchor.constraint(equalTo: delete.trailingAnchor, constant: VaultMetrics.space(1)),
            eat.heightAnchor.constraint(greaterThanOrEqualToConstant: VaultMetrics.tap),
            delete.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -VaultMetrics.space(1))
        ])
        accessibilityLabel = "\(model.title), \(model.subtitle), \(model.energy)"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
