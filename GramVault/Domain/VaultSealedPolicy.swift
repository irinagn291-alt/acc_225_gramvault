// Role: offline-first twist. Sealed mode forbids network and uses the local vault.

import Foundation

struct VaultSealedPolicy: Sendable, Hashable {
    var isSealed: Bool

    var allowsNetwork: Bool { !isSealed }

    func shouldQueryRemote(query: String, cachedCount: Int) -> Bool {
        allowsNetwork && !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func shouldResolveRemote(barcode: String, cached: VaultProduct?) -> Bool {
        allowsNetwork && cached == nil
    }
}

enum VaultCatalogFailure: Error, Sendable, Equatable {
    case sealedOffline
    case transport
    case notFound
    case missingEnergy
    case decoding
    case cancelled
    case store
    case invalidGrams
    case cameraDenied
    case cameraRestricted
    case recoveredStore

    var voice: String {
        switch self {
        case .sealedOffline:
            "The vault is sealed. Open it to fetch a product that is not already cached."
        case .transport:
            "The vault could not reach Open Food Facts. Retry or search the sealed shelf."
        case .notFound:
            "That barcode is not in Open Food Facts. Type a code or pick a shelf item."
        case .missingEnergy:
            "This product is sealed without energy data. You can still log grams."
        case .decoding:
            "The catalogue reply was unreadable. Retry the lookup."
        case .cancelled:
            "Lookup cancelled."
        case .store:
            "The local vault failed to write. Try again."
        case .invalidGrams:
            "Grams must be greater than zero and at most 10,000."
        case .cameraDenied:
            "Camera access is denied. Open Settings to let GramVault read barcodes."
        case .cameraRestricted:
            "Camera is restricted on this device. Use the typed code field."
        case .recoveredStore:
            "The vault store was rebuilt after a fault. Previous rows may be gone."
        }
    }
}
