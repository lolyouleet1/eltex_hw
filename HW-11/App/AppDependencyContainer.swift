import Foundation

final class AppDependencyContainer {
    // MARK: - Dependencies
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyFilterService: CurrencyFilterService
    private let currencySelectionService: CurrencySelectionService
    private let currencyRateService: CurrencyRateService
    private let operationFormatter: OperationFormatter
    private let tradingRunService: TradingRunService
    
    // MARK: - Lifecycle
    init() {
        let currencyRepository = MockCurrencyRepository()
        let currencyFilterService = CurrencyFilterService()
        let currencySelectionService = CurrencySelectionService()
        let currencyRateService = CurrencyRateService()
        let operationFormatter = OperationFormatter()
        let marketDataGenerator = MockMarketDataGenerator()
        let tradingEngine = TradingEngine(marketDataGenerator: marketDataGenerator)
        let tradingRunService = TradingRunService(tradingEngine: tradingEngine)
        
        self.currencyRepository = currencyRepository
        self.currencyFilterService = currencyFilterService
        self.currencySelectionService = currencySelectionService
        self.currencyRateService = currencyRateService
        self.operationFormatter = operationFormatter
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
