// Role: VIPER view. Two-page modal: detail then assign.

import SnapKit
import UIKit

@MainActor
final class AssignWizardViewController: UIViewController, AssignViewProtocol, UITextFieldDelegate {
    private let presenter: AssignPresenterOutput
    private let scroll = UIScrollView()
    private let content = UIView()
    private let backdrop = UIImageView(image: UIImage(named: "gvt_CardBackdrop"))
    private let thumb = UIImageView(image: UIImage(named: "gvt_ProductPlaceholder"))
    private let name = UILabel()
    private let brand = UILabel()
    private let energy100 = UILabel()
    private let protein100 = UILabel()
    private let carbs100 = UILabel()
    private let fat100 = UILabel()
    private let missing = UILabel()
    private let grams = UITextField()
    private let live = UILabel()
    private let wish = VaultSteelButton(title: "Add to Wish")
    private let nextButton = VaultSteelButton(title: "Next")
    private let back = VaultSteelButton(title: "Back")
    private let confirm = VaultSteelButton(title: "Seal")
    private let slotHost = UIStackView()
    private let future = UISwitch()
    private let futureLabel = UILabel()
    private let picker = UIDatePicker()
    private let dateLabel = UILabel()
    private let success = UIImageView(image: UIImage(named: "gvt_SuccessMark"))
    private let keyboard = VaultKeyboardAnchor()
    private var slotButtons: [VaultSlot: UIButton] = [:]
    private let pageOne = UIView()
    private let pageTwo = UIView()

    init(presenter: AssignPresenterOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VaultPalette.color(.background)
        build()
        presenter.handleAppear()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboard.attach(to: scroll)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboard.detach()
    }

    func render(_ model: AssignScreenModel) {
        name.text = model.name
        brand.text = model.brand
        energy100.text = "Energy \(model.energy100) kcal/100 g"
        protein100.text = "Protein \(model.protein100)"
        carbs100.text = "Carbs \(model.carbs100)"
        fat100.text = "Fat \(model.fat100)"
        missing.isHidden = !model.missingEnergy
        if grams.text != model.gramsText, !grams.isFirstResponder {
            grams.text = model.gramsText
        }
        live.text = "Now: \(model.liveEnergy) kcal · P \(model.liveProtein) · C \(model.liveCarbs) · F \(model.liveFat)"
        var wishConfig = wish.configuration
        wishConfig?.title = model.wishTitle
        wish.configuration = wishConfig
        wish.isEnabled = model.wishEnabled
        pageOne.isHidden = model.page != 0
        pageTwo.isHidden = model.page != 1
        dateLabel.text = model.dateLabel
        future.isOn = model.isFuture
        picker.isHidden = !model.isFuture
        picker.minimumDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        picker.maximumDate = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        confirm.isEnabled = model.confirmEnabled
        confirm.alpha = model.confirmBusy ? 0.5 : 1
        for (slot, button) in slotButtons {
            let selected = slot == model.slot
            button.backgroundColor = selected ? VaultPalette.color(.accent) : VaultPalette.color(.surface)
            button.setTitleColor(selected ? VaultPalette.color(.background) : VaultPalette.color(.ink), for: .normal)
            let disabled = model.isFuture && slot == .looseChange
            button.isEnabled = !disabled
            button.alpha = disabled ? 0.4 : 1
        }
    }

    func closeAfterCommit() {
        VaultHaptics.commit()
        success.isHidden = false
        VaultMotion.animate { self.success.alpha = 1 }
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            self?.presenter.handleFinished()
        }
    }

    func announce(_ message: String) {
        let alert = UIAlertController(title: "Vault", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        guard let swiftRange = Range(range, in: current) else { return false }
        let next = current.replacingCharacters(in: swiftRange, with: string)
        if next.isEmpty { return true }
        if next.contains("-") { return false }
        return VaultFormatters.parseGrams(next) != nil || next.hasSuffix(Locale.current.decimalSeparator ?? ".")
    }

    private func build() {
        scroll.alwaysBounceVertical = true
        scroll.keyboardDismissMode = .onDrag
        backdrop.contentMode = .scaleAspectFill
        backdrop.clipsToBounds = true
        backdrop.isAccessibilityElement = false
        thumb.contentMode = .scaleAspectFit
        thumb.isAccessibilityElement = false
        name.font = VaultTypography.font(.title)
        name.textColor = VaultPalette.color(.ink)
        name.numberOfLines = 2
        name.lineBreakMode = .byTruncatingTail
        name.adjustsFontForContentSizeCategory = true
        brand.font = VaultTypography.font(.caption)
        brand.textColor = VaultPalette.color(.muted)
        brand.adjustsFontForContentSizeCategory = true
        [energy100, protein100, carbs100, fat100, live, missing, futureLabel, dateLabel].forEach {
            $0.font = VaultTypography.font(.body)
            $0.textColor = VaultPalette.color(.ink)
            $0.numberOfLines = 0
            $0.adjustsFontForContentSizeCategory = true
        }
        missing.text = VaultCatalogFailure.missingEnergy.voice
        missing.textColor = VaultPalette.color(.accent)
        grams.keyboardType = .decimalPad
        grams.borderStyle = .roundedRect
        grams.font = VaultTypography.font(.numeral)
        grams.adjustsFontForContentSizeCategory = true
        grams.backgroundColor = VaultPalette.color(.surface)
        grams.textColor = VaultPalette.color(.ink)
        grams.delegate = self
        grams.accessibilityLabel = "Grams"
        grams.addAction(UIAction { [weak self] _ in
            self?.presenter.handleGrams(self?.grams.text ?? "")
        }, for: .editingChanged)
        future.accessibilityLabel = "Plan for a future date"
        futureLabel.text = "Future date"
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addAction(UIAction { [weak self] _ in
            self?.presenter.handleDate(self?.picker.date ?? Date())
        }, for: .valueChanged)
        success.alpha = 0
        success.isHidden = true
        success.isAccessibilityElement = false
        slotHost.axis = .vertical
        slotHost.spacing = VaultMetrics.space(1)
        for slot in VaultSlot.allCases {
            let button = VaultSteelButton(title: slot.title)
            button.accessibilityLabel = slot.title
            button.addAction(UIAction { [weak self] _ in self?.presenter.handleSlot(slot) }, for: .touchUpInside)
            slotButtons[slot] = button
            slotHost.addArrangedSubview(button)
        }
        nextButton.addAction(UIAction { [weak self] _ in self?.presenter.handleNext() }, for: .touchUpInside)
        back.addAction(UIAction { [weak self] _ in self?.presenter.handleBack() }, for: .touchUpInside)
        wish.addAction(UIAction { [weak self] _ in self?.presenter.handleWish() }, for: .touchUpInside)
        confirm.addAction(UIAction { [weak self] _ in self?.presenter.handleConfirm() }, for: .touchUpInside)
        future.addAction(UIAction { [weak self] _ in
            self?.presenter.handleFuture(self?.future.isOn ?? false)
        }, for: .valueChanged)
        view.addSubview(scroll)
        scroll.addSubview(content)
        content.addSubview(backdrop)
        content.addSubview(pageOne)
        content.addSubview(pageTwo)
        content.addSubview(success)
        scroll.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scroll)
        }
        backdrop.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(140)
        }
        pageOne.snp.makeConstraints { make in
            make.top.equalTo(backdrop.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview().inset(VaultMetrics.space(2))
            make.bottom.equalToSuperview().inset(VaultMetrics.space(2))
        }
        pageTwo.snp.makeConstraints { $0.edges.equalTo(pageOne) }
        [thumb, name, brand, energy100, protein100, carbs100, fat100, missing, grams, live, wish, nextButton].forEach { pageOne.addSubview($0) }
        thumb.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(72)
        }
        name.snp.makeConstraints { make in
            make.top.equalTo(thumb)
            make.leading.equalTo(thumb.snp.trailing).offset(VaultMetrics.space(1))
            make.trailing.equalToSuperview()
        }
        brand.snp.makeConstraints { make in
            make.top.equalTo(name.snp.bottom)
            make.leading.trailing.equalTo(name)
        }
        energy100.snp.makeConstraints { make in
            make.top.equalTo(thumb.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview()
        }
        protein100.snp.makeConstraints { make in
            make.top.equalTo(energy100.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        carbs100.snp.makeConstraints { make in
            make.top.equalTo(protein100.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        fat100.snp.makeConstraints { make in
            make.top.equalTo(carbs100.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        missing.snp.makeConstraints { make in
            make.top.equalTo(fat100.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.equalToSuperview()
        }
        grams.snp.makeConstraints { make in
            make.top.equalTo(missing.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(VaultMetrics.tap)
        }
        live.snp.makeConstraints { make in
            make.top.equalTo(grams.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.equalToSuperview()
        }
        wish.snp.makeConstraints { make in
            make.top.equalTo(live.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview()
        }
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(wish.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        [slotHost, future, futureLabel, picker, dateLabel, back, confirm].forEach { pageTwo.addSubview($0) }
        slotHost.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        future.snp.makeConstraints { make in
            make.top.equalTo(slotHost.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.equalToSuperview()
        }
        futureLabel.snp.makeConstraints { make in
            make.centerY.equalTo(future)
            make.leading.equalTo(future.snp.trailing).offset(VaultMetrics.space(1))
        }
        picker.snp.makeConstraints { make in
            make.top.equalTo(future.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.equalToSuperview()
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(picker.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.equalToSuperview()
        }
        back.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(VaultMetrics.space(2))
            make.leading.trailing.equalToSuperview()
        }
        confirm.snp.makeConstraints { make in
            make.top.equalTo(back.snp.bottom).offset(VaultMetrics.space(1))
            make.leading.trailing.bottom.equalToSuperview()
        }
        success.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(96)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}
