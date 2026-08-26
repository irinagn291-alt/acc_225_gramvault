// Role: VIPER router for Wish.

import UIKit

@MainActor
final class WishRouter: WishRouterProtocol {
    weak var host: UIViewController?
    var factory: VaultModalFactory?
    var onClose: (() -> Void)?

    func presentAssign(_ product: VaultProduct) {
        guard let host, let controller = factory?.makeAssign(product: product, onClose: { [weak self] in
            self?.onClose?()
        }) else { return }
        host.present(controller, animated: true)
    }

    func presentSource() {
        guard let host, let controller = factory?.makeSource(onClose: { [weak self] in
            self?.onClose?()
        }) else { return }
        host.present(controller, animated: true)
    }
}
