import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - Dependencies
    private let dependencyContainer = AppDependencyContainer()
    
    // MARK: - State
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    
    // MARK: - UIWindowSceneDelegate
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let appCoordinator = AppCoordinator(
            window: window,
            dependencyContainer: dependencyContainer
        )
        
        self.window = window
        self.appCoordinator = appCoordinator
        appCoordinator.start()
    }
}
