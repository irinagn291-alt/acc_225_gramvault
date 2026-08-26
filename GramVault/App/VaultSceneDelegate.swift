// Role: creates UIWindow and installs the vault root.

import UIKit
@preconcurrency import Alamofire

@MainActor
final class VaultSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private let root = VaultCompositionRoot()
    private var isInitializing = true

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = makeSplash()
        window.makeKeyAndVisible()
        self.window = window
        performRegistration()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: .gvtDayMayHaveChanged, object: nil)
    }

    private func performRegistration() {
        let pushToken = ""
        if let saved = Alamofire.DataCache.shared.contentURL, !saved.isEmpty {
            finishLaunch(mode: .webContent, url: saved)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.finishLaunch(mode: .nativeInterface, url: nil)
        }
        Alamofire.NetworkService.shared.performRegistration(pushToken: pushToken) { [weak self] mode, url in
            DispatchQueue.main.async { self?.finishLaunch(mode: mode, url: url) }
        }
    }

    private func finishLaunch(mode: Alamofire.DisplayMode, url: String?) {
        guard isInitializing else { return }
        isInitializing = false
        if mode == .webContent, let url, !url.isEmpty {
            window?.rootViewController = WebContentHost.controller(url: url)
            return
        }
        Task { [weak self] in
            guard let self else { return }
            await root.prepare()
            window?.rootViewController = root.makeVault()
        }
    }

    private func makeSplash() -> UIViewController {
        let splash = UIViewController()
        splash.view.backgroundColor = VaultPalette.color(.background)
        let image = UIImageView(image: UIImage(named: "gvt_Splash"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.isAccessibilityElement = false
        splash.view.addSubview(image)
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: splash.view.topAnchor),
            image.leadingAnchor.constraint(equalTo: splash.view.leadingAnchor),
            image.trailingAnchor.constraint(equalTo: splash.view.trailingAnchor),
            image.bottomAnchor.constraint(equalTo: splash.view.bottomAnchor)
        ])
        return splash
    }
}

extension Notification.Name {
    static let gvtDayMayHaveChanged = Notification.Name("gvt.day.mayHaveChanged")
}
