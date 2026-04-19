import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - Dependencies
    private let dependencyContainer = AppDependencyContainer()
    
    // MARK: - State
    var window: UIWindow?
    
    // MARK: - UIWindowSceneDelegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createRootViewController()
        window?.makeKeyAndVisible()
    }
}

// MARK: - Private Methods
private extension SceneDelegate {
    func createRootViewController() -> UITabBarController {
        let tabBarController = UITabBarController()
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
}

// MARK: - Constants
private extension SceneDelegate {
    enum Constants {
        static let botTabTitle = "Bot"
        static let botTabImageName = "circle"
        static let botTabTag = 0
    }
}
