import Foundation

final class AppDependencyContainer {
    // MARK: - Dependencies
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyFilterService: CurrencyFilterService
    private let currencySelectionService: CurrencySelectionService
    private let currencyRateService: CurrencyRateService
    private let operationFormatter: OperationFormatter
    private let tradingRunService: TradingRunService
    private let wallet: Wallet
    
    // MARK: - Lifecycle
    init() {
        let currencyRepository = MockCurrencyRepository()
        let currencyFilterService = CurrencyFilterService()
        let currencySelectionService = CurrencySelectionService()
        let currencyRateService = CurrencyRateService()
        let operationFormatter = OperationFormatter()
        let marketDataGenerator = MockMarketDataGenerator()
        let tradingEngine = TradingEngine(marketDataGenerator: marketDataGenerator)
        let startBalances = AppDependencyContainer.setStartBalances(currencyRepository: currencyRepository)
        let startCredits = AppDependencyContainer.setStartCredits(currencyRepository: currencyRepository)
        let wallet = Wallet(startBalance: startBalances, startCredits: startCredits)
        let tradingRunService = TradingRunService(tradingEngine: tradingEngine, wallet: wallet)
        
        self.currencyRepository = currencyRepository
        self.currencyFilterService = currencyFilterService
        self.currencySelectionService = currencySelectionService
        self.currencyRateService = currencyRateService
        self.operationFormatter = operationFormatter
        self.wallet = wallet
        self.tradingRunService = tradingRunService
    }
    
    // MARK: - Public Methods
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
        let graphViewControllerFactory: (TradingRunResult?) -> GraphViewController = { tradingResult in
            let viewModel = GraphViewModel(tradingResult: tradingResult)
            return GraphViewController(viewModel: viewModel)
        }
        
        let viewModel = BotViewModel(
            startBalance: AppConfiguration.Trading.startBalance,
            tradingRunService: tradingRunService,
            operationFormatter: operationFormatter,
            currencyRepository: currencyRepository,
            currencySelectionService: currencySelectionService
        )
        
        return BotViewController(
            viewModel: viewModel,
            compactCurrenciesViewControllerFactory: compactCurrenciesViewControllerFactory,
            graphViewControllerFactory: graphViewControllerFactory
        )
    }
}

// MARK: - Private Methods
private extension AppDependencyContainer {
    static func setStartBalances(currencyRepository: CurrencyRepositoryProtocol) -> [String : Float] {
        let currencies = currencyRepository.getCurrencies()
        var startBalances: [String : Float] = [:]
        
        for currency in currencies {
            startBalances[currency.code] = AppConfiguration.Trading.startBalance
        }
        
        return startBalances
    }
    
    static func setStartCredits(currencyRepository: CurrencyRepositoryProtocol) -> [String : Float] {
        let currencies = currencyRepository.getCurrencies()
        var startCredits: [String : Float] = [:]
        
        for currency in currencies {
            startCredits[currency.code] = AppConfiguration.Trading.startCredit
        }
        
        return startCredits
    }
}
