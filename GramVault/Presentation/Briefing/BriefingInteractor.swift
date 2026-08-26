// Role: VIPER interactor. Writes factory or edited targets and the briefing flag.

import Foundation

@MainActor
final class BriefingInteractor: BriefingInteractorInput {
    weak var output: BriefingPresenterOutput?
    private let aims: VaultAimRepository
    private let settings: VaultSettingsStore

    init(aims: VaultAimRepository, settings: VaultSettingsStore) {
        self.aims = aims
        self.settings = settings
    }

    func complete(_ targets: VaultDailyTargets) {
        Task { [weak self] in
            try? await self?.aims.save(targets.isValid ? targets : .factory)
            self?.settings.markBriefingComplete()
            self?.output?.interactorDidComplete()
        }
    }
}
