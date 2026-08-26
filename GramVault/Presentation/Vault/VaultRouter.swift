// Role: VIPER router. Modal presentations only. No push.

import UIKit

@MainActor
final class VaultRouter: VaultRouterProtocol {
    weak var host: UIViewController?
    var factory: VaultModalFactory?

    func presentSource() {
        guard let host, let controller = factory?.makeSource(onClose: { [weak self] in
            (self?.host as? VaultViewController)?.presenter.handleDidCloseModal()
        }) else { return }
        presentModal(controller, from: host)
    }

    func presentWish() {
        guard let host, let controller = factory?.makeWish(onClose: { [weak self] in
            (self?.host as? VaultViewController)?.presenter.handleDidCloseModal()
        }) else { return }
        presentModal(controller, from: host)
    }

    func presentTargets() {
        guard let host, let controller = factory?.makeTargets(onClose: { [weak self] in
            (self?.host as? VaultViewController)?.presenter.handleDidCloseModal()
        }) else { return }
        presentModal(controller, from: host)
    }

    func presentSealed() {
        guard let host, let controller = factory?.makeSealed() else { return }
        presentModal(controller, from: host)
    }

    func presentBriefing() {
        guard let host, let controller = factory?.makeBriefing(onDone: { [weak self] in
            (self?.host as? VaultViewController)?.presenter.handleDidCloseModal()
        }) else { return }
        controller.modalPresentationStyle = .fullScreen
        host.present(controller, animated: true)
    }

    func confirmDelete(_ id: String, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Remove seal",
            message: "Delete this row from the vault? This cannot be undone.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Keep", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in onConfirm() }))
        host?.present(alert, animated: true)
    }

    private func presentModal(_ controller: UIViewController, from host: UIViewController) {
        controller.modalPresentationStyle = .pageSheet
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        host.present(controller, animated: true)
    }
}

@MainActor
protocol VaultModalFactory: AnyObject {
    func makeSource(onClose: @escaping () -> Void) -> UIViewController
    func makeWish(onClose: @escaping () -> Void) -> UIViewController
    func makeTargets(onClose: @escaping () -> Void) -> UIViewController
    func makeSealed() -> UIViewController
    func makeBriefing(onDone: @escaping () -> Void) -> UIViewController
    func makeAssign(product: VaultProduct, onClose: @escaping () -> Void) -> UIViewController
}
