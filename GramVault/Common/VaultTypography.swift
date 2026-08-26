// Role: single type-scale accessor. DIN Condensed Bold for headers and numerals.

import UIKit

enum VaultTypography {
    enum Step: Sendable {
        case display
        case title
        case headline
        case numeral
        case body
        case caption
    }

    static func font(_ step: Step) -> UIFont {
        let point: CGFloat
        let textStyle: UIFont.TextStyle
        let condensed: Bool
        switch step {
        case .display:
            point = 40
            textStyle = .largeTitle
            condensed = true
        case .title:
            point = 28
            textStyle = .title1
            condensed = true
        case .headline:
            point = 20
            textStyle = .title3
            condensed = true
        case .numeral:
            point = 16
            textStyle = .headline
            condensed = true
        case .body:
            point = 16
            textStyle = .body
            condensed = false
        case .caption:
            point = 13
            textStyle = .caption1
            condensed = false
        }
        let base: UIFont
        if condensed, let din = UIFont(name: "DINCondensed-Bold", size: point) {
            base = din
        } else if condensed {
            base = UIFont.systemFont(ofSize: point, weight: .bold)
        } else {
            base = UIFont.systemFont(ofSize: point, weight: .regular)
        }
        return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }
}
