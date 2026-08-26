// Role: extract and normalise barcode candidates from camera, type, or URL.

import Foundation

enum VaultBarcodeNormalizer {
    static func candidates(from raw: String) -> [String] {
        let pattern = /[0-9]{8,14}/
        var seen: Set<String> = []
        var ordered: [String] = []
        for match in raw.matches(of: pattern) {
            let run = String(match.output)
            let normalised = normalise(run)
            if seen.insert(normalised).inserted {
                ordered.append(normalised)
            }
            if normalised != run, seen.insert(run).inserted {
                ordered.append(run)
            }
        }
        return ordered
    }

    static func normalise(_ run: String) -> String {
        if run.count == 12 {
            return "0" + run
        }
        return run
    }

    static func firstCandidate(from raw: String) -> String? {
        candidates(from: raw).first
    }
}
