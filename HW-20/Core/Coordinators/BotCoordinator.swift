import UIKit

protocol BotViewControllerCoordinator: AnyObject {
    func botViewControllerDidRequestWallet(_ viewController: BotViewController)
    func botViewController(_ viewController: BotViewController, didRequestCurrencySelectionFor side: SelectedSide)
}

final class BotCoordinator: Coordinator {
    // MARK: - Dependencies
    private let navigationController: UINavigationController
    private let viewModel: BotViewModel
    private let compactCurrenciesViewControllerFactory: (SelectedSide) -> CompactCurrenciesViewController
    private let walletViewControllerFactory: () -> WalletViewController
    
    // MARK: - State
    private weak var viewController: BotViewController?
    
    // MARK: - Lifecycle
    init(
        navigationController: UINavigationController,
        viewModel: BotViewModel,
        compactCurrenciesViewControllerFactory: @escaping (SelectedSide) -> CompactCurrenciesViewController,
        walletViewControllerFactory: @escaping () -> WalletViewController
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.compactCurrenciesViewControllerFactory = compactCurrenciesViewControllerFactory
        self.walletViewControllerFactory = walletViewControllerFactory
    }
    
    // MARK: - Public Methods
    func start() {
        let viewController = BotViewController(viewModel: viewModel)
        viewController.coordinator = self
        self.viewController = viewController
        
        navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: - BotViewControllerCoordinator
extension BotCoordinator: BotViewControllerCoordinator {
    func botViewControllerDidRequestWallet(_ viewController: BotViewController) {
        let walletViewController = walletViewControllerFactory()
        walletViewController.delegate = self
        let walletNavigationController = UINavigationController(rootViewController: walletViewController)
        
        viewController.present(walletNavigationController, animated: true)
    }
    
    func botViewController(_ viewController: BotViewController, didRequestCurrencySelectionFor side: SelectedSide) {
        let compactCurrenciesViewController = compactCurrenciesViewControllerFactory(side)
        compactCurrenciesViewController.delegate = self
        
        viewController.present(compactCurrenciesViewController, animated: true)
    }
}

// MARK: - CompactCurrenciesViewControllerDelegate
extension BotCoordinator: CompactCurrenciesViewControllerDelegate {
    func compactCurrenciesViewController(didSelect currency: Currency, for side: SelectedSide) {
        viewModel.handleCurrencySelection(currency, for: side)
        viewController?.dismiss(animated: true)
    }
}

// MARK: - WalletViewControllerDelegate
extension BotCoordinator: WalletViewControllerDelegate {
    func walletViewControllerDidRequestClose(_ viewController: WalletViewController) {
        viewController.dismiss(animated: true)
    }
}
