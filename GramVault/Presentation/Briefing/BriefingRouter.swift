// Role: VIPER router for briefing.

import UIKit

@MainActor
final class BriefingRouter: BriefingRouterProtocol {
    weak var host: UIViewController?
    var onDone: (() -> Void)?

    func close() {
        host?.dismiss(animated: true) { [weak self] in
            self?.onDone?()
        }
    }
}
