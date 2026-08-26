// Role: VIPER entity. The four vault chambers and snack remap rules.

import Foundation

enum VaultSlot: String, CaseIterable, Sendable, Hashable {
    case vaultA
    case vaultB
    case vaultC
    case looseChange

    var title: String {
        switch self {
        case .vaultA: "Vault A"
        case .vaultB: "Vault B"
        case .vaultC: "Vault C"
        case .looseChange: "Loose Change"
        }
    }

    var assetName: String {
        switch self {
        case .vaultA: "gvt_SlotVaultA"
        case .vaultB: "gvt_SlotVaultB"
        case .vaultC: "gvt_SlotVaultC"
        case .looseChange: "gvt_SlotLooseChange"
        }
    }

    var canPlanAhead: Bool {
        self != .looseChange
    }
}

enum VaultAssignRules {
    /// Loose Change cannot be planned. Future dates remap it to Evening (Vault C).
    static func resolvedSlot(_ slot: VaultSlot, isFuture: Bool) -> VaultSlot {
        if isFuture && slot == .looseChange {
            return .vaultC
        }
        return slot
    }

    static func isGramsValid(_ grams: Double) -> Bool {
        grams > 0 && grams <= 10_000
    }
}
