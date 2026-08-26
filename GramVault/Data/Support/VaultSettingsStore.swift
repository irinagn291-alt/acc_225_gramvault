// Role: persisted flags. UserDefaults only; no mutable statics after launch.

import Foundation

struct VaultSettingsStore: Sendable {
    private let suiteName: String?

    init(suiteName: String? = nil) {
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults {
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            return suite
        }
        return .standard
    }

    private enum Key {
        static let sealed = "gvt.sealed"
        static let briefing = "gvt.briefing.v1"
        static let demo = "gvt.demo.v1"
        static let recovered = "gvt.store.recovered"
    }

    func isSealed() -> Bool {
        defaults.bool(forKey: Key.sealed)
    }

    func setSealed(_ on: Bool) {
        defaults.set(on, forKey: Key.sealed)
    }

    func briefingComplete() -> Bool {
        defaults.bool(forKey: Key.briefing)
    }

    func markBriefingComplete() {
        defaults.set(true, forKey: Key.briefing)
    }

    func clearBriefing() {
        defaults.set(false, forKey: Key.briefing)
    }

    func consumeDemoSeedIfNeeded() -> Bool {
        if defaults.bool(forKey: Key.demo) {
            return false
        }
        defaults.set(true, forKey: Key.demo)
        return true
    }

    func markRecoveredStore() {
        defaults.set(true, forKey: Key.recovered)
    }

    func consumeRecoveredFlag() -> Bool {
        let flag = defaults.bool(forKey: Key.recovered)
        if flag {
            defaults.set(false, forKey: Key.recovered)
        }
        return flag
    }

    func resetSessionFlags() {
        defaults.set(false, forKey: Key.briefing)
        defaults.set(false, forKey: Key.sealed)
        defaults.set(false, forKey: Key.recovered)
    }
}
