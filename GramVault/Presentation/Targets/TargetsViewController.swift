// Role: VIPER view for daily targets, reset, briefing, contact.

import UIKit

@MainActor
final class TargetsViewController: UIViewController, TargetsViewProtocol, UITextFieldDelegate {
    private let presenter: TargetsPresenterOutput
    private let kcal = UITextField()
    private let protein = UITextField()
    private let carbs = UITextField()
    private let fat = UITextField()
    private let save = VaultSteelButton(title: "Seal targets")
    private let briefing = VaultSteelButton(title: "Re-run briefing")
    private let reset = VaultSteelButton(title: "Reset vault")
    private let contact = VaultSteelButton(title: "Contact")

    init(presenter: TargetsPresenterOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VaultPalette.color(.background)
        let title = UILabel()
        title.text = "TARGETS"
        title.font = VaultTypography.font(.title)
        title.textColor = VaultPalette.color(.ink)
        title.adjustsFontForContentSizeCategory = true
        title.translatesAutoresizingMaskIntoConstraints = false
        let credit = UILabel()
        credit.text = "Nutrition data is credited to Open Food Facts. GramVault is a personal food log, not medical advice."
        credit.font = VaultTypography.font(.caption)
        credit.textColor = VaultPalette.color(.muted)
        credit.numberOfLines = 0
        credit.adjustsFontForContentSizeCategory = true
        credit.translatesAutoresizingMaskIntoConstraints = false
        style(kcal, label: "Energy kcal")
        style(protein, label: "Protein g")
        style(carbs, label: "Carbs g")
        style(fat, label: "Fat g")
        kcal.addAction(UIAction { [weak self] _ in self?.presenter.handleKcal(self?.kcal.text ?? "") }, for: .editingChanged)
        protein.addAction(UIAction { [weak self] _ in self?.presenter.handleProtein(self?.protein.text ?? "") }, for: .editingChanged)
        carbs.addAction(UIAction { [weak self] _ in self?.presenter.handleCarbs(self?.carbs.text ?? "") }, for: .editingChanged)
        fat.addAction(UIAction { [weak self] _ in self?.presenter.handleFat(self?.fat.text ?? "") }, for: .editingChanged)
        save.addAction(UIAction { [weak self] _ in self?.presenter.handleSave() }, for: .touchUpInside)
        briefing.addAction(UIAction { [weak self] _ in self?.presenter.handleBriefing() }, for: .touchUpInside)
        reset.addAction(UIAction { [weak self] _ in self?.presenter.handleReset() }, for: .touchUpInside)
        contact.addAction(UIAction { [weak self] _ in self?.presenter.handleContact() }, for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [
            title,
            labeled(kcal, "Energy kcal"),
            labeled(protein, "Protein g"),
            labeled(carbs, "Carbs g"),
            labeled(fat, "Fat g"),
            save, briefing, reset, contact, credit
        ])
        stack.axis = .vertical
        stack.spacing = VaultMetrics.space(2)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: VaultMetrics.space(2)),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: VaultMetrics.space(2)),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -VaultMetrics.space(2))
        ])
        presenter.handleAppear()
    }

    func render(_ model: TargetsScreenModel) {
        if !kcal.isFirstResponder { kcal.text = model.kcal }
        if !protein.isFirstResponder { protein.text = model.protein }
        if !carbs.isFirstResponder { carbs.text = model.carbs }
        if !fat.isFirstResponder { fat.text = model.fat }
        save.isEnabled = model.saveEnabled
    }

    func announce(_ message: String) {
        if message == "Targets sealed." {
            VaultHaptics.commit()
        }
        let alert = UIAlertController(title: "Vault", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func labeled(_ field: UITextField, _ title: String) -> UIStackView {
        let caption = UILabel()
        caption.text = title
        caption.font = VaultTypography.font(.caption)
        caption.textColor = VaultPalette.color(.muted)
        caption.adjustsFontForContentSizeCategory = true
        let box = UIStackView(arrangedSubviews: [caption, field])
        box.axis = .vertical
        box.spacing = 4
        return box
    }

    private func style(_ field: UITextField, label: String) {
        field.borderStyle = .roundedRect
        field.keyboardType = .decimalPad
        field.font = VaultTypography.font(.numeral)
        field.adjustsFontForContentSizeCategory = true
        field.backgroundColor = VaultPalette.color(.surface)
        field.textColor = VaultPalette.color(.ink)
        field.accessibilityLabel = label
        field.placeholder = label
        field.delegate = self
    }
}
