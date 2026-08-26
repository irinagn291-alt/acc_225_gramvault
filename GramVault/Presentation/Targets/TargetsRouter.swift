// Role: VIPER router for Targets.

import UIKit

@MainActor
final class TargetsRouter: TargetsRouterProtocol {
    weak var host: UIViewController?
    var factory: VaultModalFactory?

    func presentBriefing() {
        guard let host, let controller = factory?.makeBriefing(onDone: {}) else { return }
        controller.modalPresentationStyle = .fullScreen
        host.present(controller, animated: true)
    }

    func openContact() {
        guard let host else { return }
        WebContentHost.presentContact(from: host)
    }

    func confirmReset(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Reset vault",
            message: "Erase every seal, wish and target on this device?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { _ in onConfirm() }))
        host?.present(alert, animated: true)
    }
}
