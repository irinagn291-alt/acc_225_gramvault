// Role: protein / carbs / fat read-out. Raw anchors.

import UIKit

final class VaultMacroStrip: UIView {
    private let stack = UIStackView()

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = VaultMetrics.space(1)
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    func render(_ items: [VaultMacroChipModel]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for item in items {
            stack.addArrangedSubview(VaultMacroChip(model: item))
        }
    }
}

struct VaultMacroChipModel: Sendable {
    var title: String
    var value: String
    var asset: String
    var filled: Bool
}

final class VaultMacroChip: UIView {
    init(model: VaultMacroChipModel) {
        super.init(frame: .zero)
        backgroundColor = VaultPalette.color(.surface)
        layer.borderWidth = 1
        layer.borderColor = VaultPalette.color(.muted).cgColor
        let icon = UIImageView(image: UIImage(named: model.asset))
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .scaleAspectFit
        icon.isAccessibilityElement = false
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = model.title
        title.font = VaultTypography.font(.caption)
        title.textColor = VaultPalette.color(.muted)
        title.adjustsFontForContentSizeCategory = true
        let value = UILabel()
        value.translatesAutoresizingMaskIntoConstraints = false
        value.text = model.value
        value.font = VaultTypography.font(.numeral)
        value.textColor = model.filled ? VaultPalette.color(.accent) : VaultPalette.color(.ink)
        value.adjustsFontForContentSizeCategory = true
        addSubview(icon)
        addSubview(title)
        addSubview(value)
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: VaultMetrics.space(1)),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 24),
            icon.heightAnchor.constraint(equalToConstant: 24),
            title.topAnchor.constraint(equalTo: topAnchor, constant: VaultMetrics.space(1)),
            title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: VaultMetrics.space(1)),
            title.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -VaultMetrics.space(1)),
            value.topAnchor.constraint(equalTo: title.bottomAnchor),
            value.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            value.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            value.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -VaultMetrics.space(1)),
            heightAnchor.constraint(greaterThanOrEqualToConstant: VaultMetrics.tap)
        ])
        accessibilityLabel = "\(model.title) \(model.value)"
        isAccessibilityElement = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
