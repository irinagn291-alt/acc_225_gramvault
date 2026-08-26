// Role: designed empty state with generated art, headline, copy, and an action.

import UIKit

final class VaultEmptyPanel: UIView {
    let action = VaultSteelButton(title: "Open Source")

    private let art = UIImageView()
    private let headline = UILabel()
    private let body = UILabel()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        art.translatesAutoresizingMaskIntoConstraints = false
        headline.translatesAutoresizingMaskIntoConstraints = false
        body.translatesAutoresizingMaskIntoConstraints = false
        art.contentMode = .scaleAspectFit
        art.isAccessibilityElement = false
        headline.font = VaultTypography.font(.headline)
        headline.textColor = VaultPalette.color(.ink)
        headline.textAlignment = .center
        headline.numberOfLines = 0
        headline.adjustsFontForContentSizeCategory = true
        body.font = VaultTypography.font(.body)
        body.textColor = VaultPalette.color(.muted)
        body.textAlignment = .center
        body.numberOfLines = 0
        body.adjustsFontForContentSizeCategory = true
        addSubview(art)
        addSubview(headline)
        addSubview(body)
        addSubview(action)
        NSLayoutConstraint.activate([
            art.topAnchor.constraint(equalTo: topAnchor),
            art.centerXAnchor.constraint(equalTo: centerXAnchor),
            art.widthAnchor.constraint(equalToConstant: 160),
            art.heightAnchor.constraint(equalToConstant: 160),
            headline.topAnchor.constraint(equalTo: art.bottomAnchor, constant: VaultMetrics.space(2)),
            headline.leadingAnchor.constraint(equalTo: leadingAnchor),
            headline.trailingAnchor.constraint(equalTo: trailingAnchor),
            body.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: VaultMetrics.space(1)),
            body.leadingAnchor.constraint(equalTo: leadingAnchor),
            body.trailingAnchor.constraint(equalTo: trailingAnchor),
            action.topAnchor.constraint(equalTo: body.bottomAnchor, constant: VaultMetrics.space(2)),
            action.centerXAnchor.constraint(equalTo: centerXAnchor),
            action.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func apply(image: String, title: String, copy: String, actionTitle: String) {
        art.image = UIImage(named: image)
        headline.text = title
        body.text = copy
        action.setTitle(actionTitle, for: .normal)
        var config = action.configuration
        config?.title = actionTitle
        action.configuration = config
    }
}
