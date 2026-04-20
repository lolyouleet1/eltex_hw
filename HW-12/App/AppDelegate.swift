import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - UIApplicationDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    // MARK: - UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(
            name: Constants.sceneConfigurationName,
            sessionRole: connectingSceneSession.role
        )
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

// MARK: - Constants
private extension AppDelegate {
    enum Constants {
        static let sceneConfigurationName = "Default Configuration"
    }
}
