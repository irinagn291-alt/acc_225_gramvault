// Role: VIPER router for the assign wizard.

import UIKit

@MainActor
final class AssignRouter: AssignRouterProtocol {
    weak var host: UIViewController?
    var onClose: (() -> Void)?

    func close() {
        host?.dismiss(animated: true) { [weak self] in
            self?.onClose?()
        }
    }
}
