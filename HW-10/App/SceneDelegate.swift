import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = createRootViewController()
        window?.makeKeyAndVisible()
    }
}

private extension SceneDelegate {
    func createRootViewController() -> UITabBarController {
        let tabBarContoller = UITabBarController()
        
        let session = TradingSession(startBalance: AppConfiguration.Stock.startBalance)
        
        let botViewController = BotViewController(tradingSession: session)
        botViewController.tabBarItem = UITabBarItem(title: "Bot", image: UIImage(systemName: "circle"), tag: 0)
        let navigationController = UINavigationController(rootViewController: botViewController)
        
        tabBarContoller.viewControllers = [navigationController]
        
        return tabBarContoller
    }
}
