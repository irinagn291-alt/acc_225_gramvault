// Role: primary machined control. Simple view, raw anchors.

import UIKit

final class VaultSteelButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = VaultPalette.color(.accent)
        config.baseForegroundColor = VaultPalette.color(.background)
        config.title = title
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = VaultTypography.font(.headline)
            return outgoing
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        configuration = config
        heightAnchor.constraint(greaterThanOrEqualToConstant: VaultMetrics.tap).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
