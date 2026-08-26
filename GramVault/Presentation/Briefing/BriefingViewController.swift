// Role: VIPER view. Four-page first-run briefing.

import UIKit

@MainActor
final class BriefingViewController: UIViewController, BriefingViewProtocol {
    private let presenter: BriefingPresenterOutput
    private let art = UIImageView()
    private let titleLabel = UILabel()
    private let copyLabel = UILabel()
    private let kcal = UITextField()
    private let protein = UITextField()
    private let carbs = UITextField()
    private let fat = UITextField()
    private let nextButton = VaultSteelButton(title: "Next")
    private let skip = VaultSteelButton(title: "Skip with factory set")
    private let fields = UIStackView()

    init(presenter: BriefingPresenterOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VaultPalette.color(.background)
        art.translatesAutoresizingMaskIntoConstraints = false
        art.contentMode = .scaleAspectFill
        art.clipsToBounds = true
        art.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = VaultTypography.font(.title)
        titleLabel.textColor = VaultPalette.color(.ink)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        copyLabel.translatesAutoresizingMaskIntoConstraints = false
        copyLabel.font = VaultTypography.font(.body)
        copyLabel.textColor = VaultPalette.color(.muted)
        copyLabel.numberOfLines = 0
        copyLabel.adjustsFontForContentSizeCategory = true
        [kcal, protein, carbs, fat].forEach { field in
            field.borderStyle = .roundedRect
            field.keyboardType = .decimalPad
            field.font = VaultTypography.font(.numeral)
            field.adjustsFontForContentSizeCategory = true
            field.backgroundColor = VaultPalette.color(.surface)
            field.textColor = VaultPalette.color(.ink)
        }
        kcal.accessibilityLabel = "Energy kcal"
        protein.accessibilityLabel = "Protein g"
        carbs.accessibilityLabel = "Carbs g"
        fat.accessibilityLabel = "Fat g"
        kcal.addAction(UIAction { [weak self] _ in self?.presenter.handleKcal(self?.kcal.text ?? "") }, for: .editingChanged)
        protein.addAction(UIAction { [weak self] _ in self?.presenter.handleProtein(self?.protein.text ?? "") }, for: .editingChanged)
        carbs.addAction(UIAction { [weak self] _ in self?.presenter.handleCarbs(self?.carbs.text ?? "") }, for: .editingChanged)
        fat.addAction(UIAction { [weak self] _ in self?.presenter.handleFat(self?.fat.text ?? "") }, for: .editingChanged)
        fields.axis = .vertical
        fields.spacing = VaultMetrics.space(1)
        fields.translatesAutoresizingMaskIntoConstraints = false
        [kcal, protein, carbs, fat].forEach { fields.addArrangedSubview($0) }
        nextButton.addAction(UIAction { [weak self] _ in self?.presenter.handleNext() }, for: .touchUpInside)
        skip.addAction(UIAction { [weak self] _ in self?.presenter.handleSkip() }, for: .touchUpInside)
        [art, titleLabel, copyLabel, fields, nextButton, skip].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            art.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: VaultMetrics.space(2)),
            art.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: VaultMetrics.space(2)),
            art.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -VaultMetrics.space(2)),
            art.heightAnchor.constraint(equalTo: art.widthAnchor, multiplier: 0.66),
            titleLabel.topAnchor.constraint(equalTo: art.bottomAnchor, constant: VaultMetrics.space(2)),
            titleLabel.leadingAnchor.constraint(equalTo: art.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: art.trailingAnchor),
            copyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: VaultMetrics.space(1)),
            copyLabel.leadingAnchor.constraint(equalTo: art.leadingAnchor),
            copyLabel.trailingAnchor.constraint(equalTo: art.trailingAnchor),
            fields.topAnchor.constraint(equalTo: copyLabel.bottomAnchor, constant: VaultMetrics.space(2)),
            fields.leadingAnchor.constraint(equalTo: art.leadingAnchor),
            fields.trailingAnchor.constraint(equalTo: art.trailingAnchor),
            skip.leadingAnchor.constraint(equalTo: art.leadingAnchor),
            skip.trailingAnchor.constraint(equalTo: art.trailingAnchor),
            skip.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -VaultMetrics.space(2)),
            nextButton.leadingAnchor.constraint(equalTo: art.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: art.trailingAnchor),
            nextButton.bottomAnchor.constraint(equalTo: skip.topAnchor, constant: -VaultMetrics.space(1))
        ])
        presenter.handleAppear()
    }

    func render(_ model: BriefingScreenModel) {
        art.image = UIImage(named: model.image)
        titleLabel.text = model.title
        copyLabel.text = model.copy
        fields.isHidden = !model.showsTargets
        kcal.text = model.kcal
        protein.text = model.protein
        carbs.text = model.carbs
        fat.text = model.fat
        var config = nextButton.configuration
        config?.title = model.nextTitle
        nextButton.configuration = config
    }

    func finish() {}
}
