// Role: locale-aware number and energy formatting. Round only at display.

import Foundation

enum VaultFormatters {
    static let energy: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static let macro: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static let grams: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.generatesDecimalNumbers = true
        return formatter
    }()

    static func energyText(_ value: Double?) -> String {
        guard let value else { return "—" }
        return energy.string(from: NSNumber(value: value.rounded())) ?? "—"
    }

    static func macroText(_ value: Double?) -> String {
        guard let value else { return "unknown" }
        return macro.string(from: NSNumber(value: value)) ?? "unknown"
    }

    static func parseGrams(_ raw: String) -> Double? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        return grams.number(from: trimmed)?.doubleValue
    }
}
