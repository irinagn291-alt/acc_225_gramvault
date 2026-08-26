// Role: VIPER router for Source. Modal assign only.

import UIKit

@MainActor
final class SourceRouter: SourceRouterProtocol {
    weak var host: UIViewController?
    var factory: VaultModalFactory?
    var onClose: (() -> Void)?

    func presentAssign(_ product: VaultProduct) {
        guard let host, let controller = factory?.makeAssign(product: product, onClose: { [weak self] in
            self?.onClose?()
            self?.host?.dismiss(animated: true)
        }) else { return }
        controller.modalPresentationStyle = .pageSheet
        host.present(controller, animated: true)
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
