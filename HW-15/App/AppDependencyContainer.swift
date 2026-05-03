import Foundation

final class AppDependencyContainer {
    // MARK: - Dependencies
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyFilterService: CurrencyFilterService
    private let currencySelectionService: CurrencySelectionService
    private let currencyRateService: CurrencyRateService
    private let operationFormatter: OperationFormatter
    private let tradingRunService: TradingRunService
    private let tradeBotNameProvider: TradeBotNameProvider
    private let networkService: NetworkServiceProtocol
    private let p2pOfferFactory: P2POfferFactory
    private let wallet: Wallet
    private let authService: AuthServiceProtocol
    
    // MARK: - Lifecycle
    init() {
        let currencyRepository = MockCurrencyRepository()
        let currencyFilterService = CurrencyFilterService()
        let currencySelectionService = CurrencySelectionService()
        let currencyRateService = CurrencyRateService()
        let operationFormatter = OperationFormatter()
        let networkService = NetworkService()
        let p2pOfferFactory = P2POfferFactory()
        let marketDataGenerator = MockMarketDataGenerator()
        let tradingEngine = TradingEngine(marketDataGenerator: marketDataGenerator)
        let startBalances = AppDependencyContainer.setStartBalances(currencyRepository: currencyRepository)
        let startCredits = AppDependencyContainer.setStartCredits(currencyRepository: currencyRepository)
        let wallet = Wallet(startBalance: startBalances, startCredits: startCredits)
        let tradingRunService = TradingRunService(tradingEngine: tradingEngine, wallet: wallet)
        let tradeBotNameProvider = TradeBotNameProvider()
        let authService = AuthService()
        
        self.currencyRepository = currencyRepository
        self.currencyFilterService = currencyFilterService
        self.currencySelectionService = currencySelectionService
        self.currencyRateService = currencyRateService
        self.operationFormatter = operationFormatter
        self.wallet = wallet
        self.tradingRunService = tradingRunService
        self.tradeBotNameProvider = tradeBotNameProvider
        self.networkService = networkService
        self.p2pOfferFactory = p2pOfferFactory
        self.authService = authService
    }
    
    // MARK: - Public Methods
    func shouldStartAuthorized() -> Bool {
        authService.canAutoLogin
    }
    
    func makeAuthViewController() -> AuthViewController {
        let viewModel = AuthViewModel(authService: authService)
        
        return AuthViewController(viewModel: viewModel)
    }
    
    func makeBotViewController() -> BotViewController {
        let currencyRepository = currencyRepository
        let currencyFilterService = currencyFilterService
        let currencySelectionService = currencySelectionService
        
        let compactCurrenciesViewControllerFactory: (SelectedSide) -> CompactCurrenciesViewController = { selectionSide in
            let viewModel = CompactCurrenciesViewModel(
                selectionSide: selectionSide,
                currencyRepository: currencyRepository,
                currencyFilterService: currencyFilterService,
                currencySelectionService: currencySelectionService
            )
            
            return CompactCurrenciesViewController(viewModel: viewModel)
        }
        
        let walletViewControllerFactory: () -> WalletViewController = { [wallet, operationFormatter] in
            WalletViewController(wallet: wallet, operationFormatter: operationFormatter)
        }
//        let graphViewControllerFactory: (TradingRunResult?) -> GraphViewController = { tradingResult in
//            let viewModel = GraphViewModel(tradingResult: tradingResult)
//            return GraphViewController(viewModel: viewModel)
//        }
        
        let viewModel = BotViewModel(
            tradingRunService: tradingRunService,
            operationFormatter: operationFormatter,
            currencyRepository: currencyRepository,
            currencySelectionService: currencySelectionService,
            tradeBotNameProvider: tradeBotNameProvider
        )
        
        return BotViewController(
            viewModel: viewModel,
            compactCurrenciesViewControllerFactory: compactCurrenciesViewControllerFactory,
            walletViewControllerFactory: walletViewControllerFactory
//            graphViewControllerFactory: graphViewControllerFactory
        )
    }
    
    func makeP2PExchangeViewController() -> P2PExchangeViewController {
        let currencyRepository = currencyRepository
        let currencyFilterService = currencyFilterService
        let currencySelectionService = CurrencySelectionService()
        
        let compactCurrenciesViewControllerFactory: (SelectedSide, [Currency]) -> CompactCurrenciesViewController = { selectionSide, currencies in
            let viewModel = CompactCurrenciesViewModel(
                selectionSide: selectionSide,
                currencyRepository: currencyRepository,
                currencyFilterService: currencyFilterService,
                currencySelectionService: currencySelectionService,
                currencySource: .apiOnly(currencies),
                activeFilter: .all
            )
            
            return CompactCurrenciesViewController(viewModel: viewModel)
        }
        
        let walletViewControllerFactory: () -> WalletViewController = { [wallet, operationFormatter] in
            WalletViewController(wallet: wallet, operationFormatter: operationFormatter)
        }
        
        let viewModel = P2PExchangeViewModel(
            networkService: networkService,
            wallet: wallet,
            offerFactory: p2pOfferFactory,
            currencySelectionService: currencySelectionService
        )
        
        return P2PExchangeViewController(
            viewModel: viewModel,
            compactCurrenciesViewControllerFactory: compactCurrenciesViewControllerFactory,
            walletViewControllerFactory: walletViewControllerFactory
        )
    }
    
    func makeSettingsViewController() -> SettingsViewController {
        let viewModel = SettingsViewModel(authService: authService)
        
        return SettingsViewController(viewModel: viewModel)
    }
}

// MARK: - Private Methods
private extension AppDependencyContainer {
    static func setStartBalances(currencyRepository: CurrencyRepositoryProtocol) -> [String: Float] {
        let currencies = currencyRepository.getCurrencies()
        var startBalances: [String: Float] = [:]
        
        for currency in currencies {
            startBalances[currency.code] = AppConfiguration.Trading.startBalance
        }
        
        return startBalances
    }
    
    static func setStartCredits(currencyRepository: CurrencyRepositoryProtocol) -> [String: Float] {
        let currencies = currencyRepository.getCurrencies()
        var startCredits: [String: Float] = [:]
        
        for currency in currencies {
            startCredits[currency.code] = AppConfiguration.Trading.startCredit
        }
        
        return startCredits
    }
}
