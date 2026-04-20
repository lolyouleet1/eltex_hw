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
        
        tabBarController.viewControllers = [
            botNavigationController
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
}

// MARK: - SplashFinishedProtocol
extension SceneDelegate: SplashFinishedProtocol {
    func splashDidFinished() {
        let newRootViewController = createRootViewController()
        
        guard let window else { return }
        
        UIView.transition(
            with: window,
            duration: 0.35,
            options: [.transitionCrossDissolve],
            animations: {
                window.rootViewController = newRootViewController
            },
            completion: nil
        )
    }
}

// MARK: - Constants
private extension SceneDelegate {
    enum Constants {
        static let botTabTitle = "Bot"
        static let botTabImageName = "circle"
        static let botTabTag = 0
        static let primaryColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let tabBarShadowColor: UIColor = .clear
        static let tabBarItemWidth: CGFloat = 112
    }
}
