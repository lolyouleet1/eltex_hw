import UIKit

final class AppCoordinator: Coordinator {
    // MARK: - Dependencies
    private let window: UIWindow
    private let dependencyContainer: AppDependencyContainer
    private let splashScreen = SplashScreenViewController()
    
    // MARK: - State
    private var childCoordinators: [Coordinator] = []
    
    // MARK: - Lifecycle
    init(window: UIWindow, dependencyContainer: AppDependencyContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
    }
    
    // MARK: - Public Methods
    func start() {
        splashScreen.delegate = self
        window.rootViewController = splashScreen
        window.makeKeyAndVisible()
    }
}

// MARK: - Private Methods
private extension AppCoordinator {
    func createAuthViewController() -> AuthViewController {
        childCoordinators.removeAll()
        
        let viewController = dependencyContainer.makeAuthViewController()
        viewController.delegate = self
        
        return viewController
    }
    
    func createRootViewController() -> UITabBarController {
        let tabBarController = UITabBarController()
        configureTabBar(tabBarController.tabBar)
        
        let botNavigationController = UINavigationController()
        let botCoordinator = dependencyContainer.makeBotCoordinator(
            navigationController: botNavigationController
        )
        botNavigationController.tabBarItem = UITabBarItem(
            title: Constants.botTabTitle,
            image: UIImage(systemName: Constants.botTabImageName),
            tag: Constants.botTabTag
        )
        botCoordinator.start()
        
        let p2pNavigationController = UINavigationController()
        let p2pCoordinator = dependencyContainer.makeP2PExchangeCoordinator(
            navigationController: p2pNavigationController
        )
        p2pNavigationController.tabBarItem = UITabBarItem(
            title: Constants.p2pTabTitle,
            image: UIImage(systemName: Constants.p2pTabImageName),
            tag: Constants.p2pTabTag
        )
        p2pCoordinator.start()
        
        let settingsViewController = dependencyContainer.makeSettingsViewController()
        settingsViewController.delegate = self
        settingsViewController.tabBarItem = UITabBarItem(
            title: Constants.settingsTabTitle,
            image: UIImage(systemName: Constants.settingsTabImageName),
            tag: Constants.settingsTabTag
        )
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        
        childCoordinators = [
            botCoordinator,
            p2pCoordinator
        ]
        tabBarController.viewControllers = [
            botNavigationController,
            p2pNavigationController,
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
        UIView.transition(
            with: window,
            duration: Constants.rootTransitionDuration,
            options: [.transitionCrossDissolve],
            animations: {
                self.window.rootViewController = viewController
            },
            completion: nil
        )
    }
}

// MARK: - SplashFinishedProtocol
extension AppCoordinator: SplashFinishedProtocol {
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
extension AppCoordinator: AuthViewControllerDelegate {
    func authViewControllerDidAuthorize(_ viewController: AuthViewController) {
        setRootViewController(createRootViewController())
    }
}

// MARK: - SettingsViewControllerDelegate
extension AppCoordinator: SettingsViewControllerDelegate {
    func settingsViewControllerDidLogout(_ viewController: SettingsViewController) {
        setRootViewController(createAuthViewController())
    }
}

// MARK: - Constants
private extension AppCoordinator {
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
