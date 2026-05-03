import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - Dependencies
    private let dependencyContainer = AppDependencyContainer()
    private let splashScreen = SplashScreenViewController()
    
    // MARK: - State
    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        splashScreen.delegate = self
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = splashScreen
        window?.makeKeyAndVisible()
    }
}

// MARK: - Private Methods
private extension SceneDelegate {
    func createAuthViewController() -> AuthViewController {
        let viewController = dependencyContainer.makeAuthViewController()
        viewController.delegate = self
        
        return viewController
    }
    
    func createRootViewController() -> UITabBarController {
        let tabBarController = UITabBarController()
        configureTabBar(tabBarController.tabBar)
        
        let botViewController = dependencyContainer.makeBotViewController()
        botViewController.tabBarItem = UITabBarItem(
            title: Constants.botTabTitle,
            image: UIImage(systemName: Constants.botTabImageName),
            tag: Constants.botTabTag
        )
        let botNavigationController = UINavigationController(rootViewController: botViewController)
        
        let p2pViewController = dependencyContainer.makeP2PExchangeViewController()
        p2pViewController.tabBarItem = UITabBarItem(
            title: Constants.p2pTabTitle,
            image: UIImage(systemName: Constants.p2pTabImageName),
            tag: Constants.p2pTabTag
        )
        let p2pExchangeController = UINavigationController(rootViewController: p2pViewController)
        
        let settingsViewController = dependencyContainer.makeSettingsViewController()
        settingsViewController.delegate = self
        settingsViewController.tabBarItem = UITabBarItem(
            title: Constants.settingsTabTitle,
            image: UIImage(systemName: Constants.settingsTabImageName),
            tag: Constants.settingsTabTag
        )
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        
        tabBarController.viewControllers = [
            botNavigationController,
            p2pExchangeController,
            settingsNavigationController
        ]
        
        return tabBarController
    }
    
    func configureTabBar(_ tabBar: UITabBar) {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = Constants.tabBarShadowColor
        appearance.stackedLayoutAppearance.selected.iconColor = Constants.primaryColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: Constants.primaryColor
        ]
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = Constants.primaryColor
        tabBar.unselectedItemTintColor = Constants.primaryColor
        tabBar.itemPositioning = .centered
        tabBar.itemWidth = Constants.tabBarItemWidth
    }
    
    func setRootViewController(_ viewController: UIViewController) {
        guard let window else { return }
        
        UIView.transition(
            with: window,
            duration: Constants.rootTransitionDuration,
            options: [.transitionCrossDissolve],
            animations: {
                window.rootViewController = viewController
            },
            completion: nil
        )
    }
}

// MARK: - SplashFinishedProtocol
extension SceneDelegate: SplashFinishedProtocol {
    func splashDidFinished() {
        let newRootViewController: UIViewController
        
        if dependencyContainer.shouldStartAuthorized() {
            newRootViewController = createRootViewController()
        } else {
            newRootViewController = createAuthViewController()
        }
        
        setRootViewController(newRootViewController)
    }
}

// MARK: - AuthViewControllerDelegate
extension SceneDelegate: AuthViewControllerDelegate {
    func authViewControllerDidAuthorize(_ viewController: AuthViewController) {
        setRootViewController(createRootViewController())
    }
}

// MARK: - SettingsViewControllerDelegate
extension SceneDelegate: SettingsViewControllerDelegate {
    func settingsViewControllerDidLogout(_ viewController: SettingsViewController) {
        setRootViewController(createAuthViewController())
    }
}

// MARK: - Constants
private extension SceneDelegate {
    enum Constants {
        static let botTabTitle = "Bot"
        static let p2pTabTitle = "P2P"
        static let settingsTabTitle = "Настройки"
        static let botTabImageName = "circle"
        static let p2pTabImageName = "digitalcrown.horizontal.fill"
        static let settingsTabImageName = "gearshape"
        static let botTabTag = 0
        static let p2pTabTag = 1
        static let settingsTabTag = 2
        static let primaryColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let tabBarShadowColor: UIColor = .clear
        static let tabBarItemWidth: CGFloat = 112
        static let rootTransitionDuration: TimeInterval = 0.35
    }
}
