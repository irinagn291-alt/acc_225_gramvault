// Role: typed colour accessor. The only place hex values may appear.

import UIKit

enum VaultPalette {
    enum Token: String, Sendable {
        case background
        case surface
        case ink
        case accent
        case muted
    }

    static func color(_ token: Token) -> UIColor {
        UIColor(named: token.rawValue) ?? fallback(token)
    }

    private static func fallback(_ token: Token) -> UIColor {
        switch token {
        case .background: UIColor(red: 44 / 255, green: 51 / 255, blue: 56 / 255, alpha: 1)
        case .surface: UIColor(red: 55 / 255, green: 62 / 255, blue: 68 / 255, alpha: 1)
        case .ink: UIColor(red: 232 / 255, green: 236 / 255, blue: 239 / 255, alpha: 1)
        case .accent: UIColor(red: 1, green: 179 / 255, blue: 0, alpha: 1)
        case .muted: UIColor(red: 138 / 255, green: 147 / 255, blue: 154 / 255, alpha: 1)
        }
    }
}
