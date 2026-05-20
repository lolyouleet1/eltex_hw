import UIKit

protocol P2PExchangeViewControllerCoordinator: AnyObject {
    func p2pExchangeViewControllerDidRequestWallet(_ viewController: P2PExchangeViewController)
    func p2pExchangeViewController(_ viewController: P2PExchangeViewController, didRequestCurrencySelectionFor side: SelectedSide)
    func p2pExchangeViewController(_ viewController: P2PExchangeViewController, didRequestSellerInfoFor offerIndex: Int)
}

final class P2PExchangeCoordinator: Coordinator {
    // MARK: - Dependencies
    private let navigationController: UINavigationController
    private let viewModel: P2PExchangeViewModel
    private let compactCurrenciesViewControllerFactory: (SelectedSide, [Currency]) -> CompactCurrenciesViewController
    private let walletViewControllerFactory: () -> WalletViewController
    
    // MARK: - State
    private weak var viewController: P2PExchangeViewController?
    
    // MARK: - Lifecycle
    init(
        navigationController: UINavigationController,
        viewModel: P2PExchangeViewModel,
        compactCurrenciesViewControllerFactory: @escaping (SelectedSide, [Currency]) -> CompactCurrenciesViewController,
        walletViewControllerFactory: @escaping () -> WalletViewController
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
        self.compactCurrenciesViewControllerFactory = compactCurrenciesViewControllerFactory
        self.walletViewControllerFactory = walletViewControllerFactory
    }
    
    // MARK: - Public Methods
    func start() {
        let viewController = P2PExchangeViewController(viewModel: viewModel)
        viewController.coordinator = self
        self.viewController = viewController
        
        navigationController.setViewControllers([viewController], animated: false)
    }
}

// MARK: - P2PExchangeViewControllerCoordinator
extension P2PExchangeCoordinator: P2PExchangeViewControllerCoordinator {
    func p2pExchangeViewControllerDidRequestWallet(_ viewController: P2PExchangeViewController) {
        let walletViewController = walletViewControllerFactory()
        walletViewController.delegate = self
        let walletNavigationController = UINavigationController(rootViewController: walletViewController)
        
        viewController.present(walletNavigationController, animated: true)
    }
    
    func p2pExchangeViewController(_ viewController: P2PExchangeViewController, didRequestCurrencySelectionFor side: SelectedSide) {
        let compactCurrenciesViewController = compactCurrenciesViewControllerFactory(
            side,
            viewModel.availableCurrencies()
        )
        compactCurrenciesViewController.delegate = self
        
        viewController.present(compactCurrenciesViewController, animated: true)
    }
    
    func p2pExchangeViewController(_ viewController: P2PExchangeViewController, didRequestSellerInfoFor offerIndex: Int) {
        guard let offer = viewModel.offer(at: offerIndex) else { return }
        
        let sellerInfoViewModel = P2PSellerInfoViewModel(offer: offer)
        let sellerInfoViewController = P2PSellerInfoViewController(viewModel: sellerInfoViewModel)
        
        navigationController.pushViewController(sellerInfoViewController, animated: true)
    }
}

// MARK: - CompactCurrenciesViewControllerDelegate
extension P2PExchangeCoordinator: CompactCurrenciesViewControllerDelegate {
    func compactCurrenciesViewController(didSelect currency: Currency, for side: SelectedSide) {
        viewModel.handleCurrencySelection(currency, for: side)
        viewController?.dismiss(animated: true)
    }
}

// MARK: - WalletViewControllerDelegate
extension P2PExchangeCoordinator: WalletViewControllerDelegate {
    func walletViewControllerDidRequestClose(_ viewController: WalletViewController) {
        viewController.dismiss(animated: true)
    }
}
