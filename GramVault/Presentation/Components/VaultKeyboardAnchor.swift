// Role: keep the focused field visible above the keyboard.

import UIKit

@MainActor
final class VaultKeyboardAnchor {
    private weak var scroll: UIScrollView?
    private var show: NSObjectProtocol?
    private var hide: NSObjectProtocol?

    func attach(to scroll: UIScrollView) {
        detach()
        self.scroll = scroll
        show = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            Task { @MainActor [weak self] in
                self?.adjust(frame)
            }
        }
        hide = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.scroll?.contentInset.bottom = 0
                self?.scroll?.verticalScrollIndicatorInsets.bottom = 0
            }
        }
    }

    func detach() {
        if let show { NotificationCenter.default.removeObserver(show) }
        if let hide { NotificationCenter.default.removeObserver(hide) }
        show = nil
        hide = nil
    }

    private func adjust(_ frame: CGRect?) {
        guard let scroll, let frame else { return }
        let converted = scroll.convert(frame, from: nil)
        let overlap = max(0, scroll.bounds.maxY - converted.minY)
        scroll.contentInset.bottom = overlap
        scroll.verticalScrollIndicatorInsets.bottom = overlap
    }
}
