// Role: VIPER view for the offline-first twist.

import UIKit

@MainActor
final class SealedViewController: UIViewController, SealedViewProtocol {
    private let presenter: SealedPresenterOutput
    private let art = UIImageView(image: UIImage(named: "gvt_TwistHero"))
    private let titleLabel = UILabel()
    private let copyLabel = UILabel()
    private let cached = UILabel()

    init(presenter: SealedPresenterOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = VaultPalette.color(.background)
        art.translatesAutoresizingMaskIntoConstraints = false
        art.contentMode = .scaleAspectFit
        art.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = VaultTypography.font(.title)
        titleLabel.textColor = VaultPalette.color(.accent)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        copyLabel.translatesAutoresizingMaskIntoConstraints = false
        copyLabel.font = VaultTypography.font(.body)
        copyLabel.textColor = VaultPalette.color(.ink)
        copyLabel.numberOfLines = 0
        copyLabel.adjustsFontForContentSizeCategory = true
        cached.translatesAutoresizingMaskIntoConstraints = false
        cached.font = VaultTypography.font(.numeral)
        cached.textColor = VaultPalette.color(.muted)
        cached.adjustsFontForContentSizeCategory = true
        [art, titleLabel, copyLabel, cached].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            art.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: VaultMetrics.space(2)),
            art.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            art.widthAnchor.constraint(equalToConstant: 180),
            art.heightAnchor.constraint(equalToConstant: 180),
            titleLabel.topAnchor.constraint(equalTo: art.bottomAnchor, constant: VaultMetrics.space(2)),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: VaultMetrics.space(2)),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -VaultMetrics.space(2)),
            copyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: VaultMetrics.space(1)),
            copyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            copyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            cached.topAnchor.constraint(equalTo: copyLabel.bottomAnchor, constant: VaultMetrics.space(2)),
            cached.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            cached.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        presenter.handleAppear()
    }

    func render(_ model: SealedScreenModel) {
        titleLabel.text = model.title
        copyLabel.text = model.copy
        cached.text = model.cached
    }
}
