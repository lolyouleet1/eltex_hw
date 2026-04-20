import Foundation

final class BotViewModel {
    struct ViewState {
        let balanceText: String
        let profitText: String
        let balanceTone: ResultTone
        let profitTone: ResultTone
        let operations: [OperationCellViewModel]
        let isWarningHidden: Bool
        let isTableHidden: Bool
        let leftCurrencyText: String
        let rightCurrencyText: String
    }
    
    // MARK: - Dependencies
    private let startBalance: Float
    private let tradingRunService: TradingRunService
    private let operationFormatter: OperationFormatter
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencySelectionService: CurrencySelectionService
    
    // MARK: - State
    private var tradingResult: TradingRunResult?
    private(set) var viewState: ViewState
    private var operations: [Operation] = []
    var onStateChange: ((ViewState) -> Void)?
    private var timer: Timer?
    var onTradingResultChange: ((TradingRunResult?) -> Void)?
    
    // MARK: - Lifecycle
    init(startBalance: Float, tradingRunService: TradingRunService, operationFormatter: OperationFormatter, currencyRepository: CurrencyRepositoryProtocol, currencySelectionService: CurrencySelectionService) {
        self.startBalance = startBalance
        self.tradingRunService = tradingRunService
        self.operationFormatter = operationFormatter
        self.currencyRepository = currencyRepository
        self.currencySelectionService = currencySelectionService
        self.viewState = ViewState(
            balanceText: Constants.emptyText,
            profitText: Constants.emptyText,
            balanceTone: .neutral,
            profitTone: .neutral,
            operations: [],
            isWarningHidden: false,
            isTableHidden: true,
            leftCurrencyText: Constants.defaultCurrencyText,
            rightCurrencyText: Constants.defaultCurrencyText
        )
        
        rebuildState()
    }
    
    deinit {
        stopLiveUpdates()
    }
    
    // MARK: - Public Methods
    func handleStart(cyclesText: String?, isBotEnabled: Bool) {
        guard let text = cyclesText?.trimmingCharacters(in: .whitespacesAndNewlines),
              let cycles = Int(text),
              cycles > .zero else { return }
        guard isBotEnabled, isCurrencySet else { return }
        
        let result = tradingRunService.makeResult(
            startBalance: startBalance,
            cycles: cycles
        )
        tradingResult = result
        
        operations = result.operations
        
        startLiveUpdates()
        rebuildState()
        
        onStateChange?(viewState)
        onTradingResultChange?(tradingResult)
    }
    
    func handleClear() {
        tradingResult = nil
        stopLiveUpdates()
        operations.removeAll()
        rebuildState()
        
        onStateChange?(viewState)
        onTradingResultChange?(nil)
    }
    
    func handleRandomCurrencies() {
        _ = currencySelectionService.selectRandomPair(from: currencyRepository.getCurrencies())
        rebuildState()
    }
    
    func handleCurrencySelection(_ currency: Currency, for side: SelectedSide) {
        guard currencySelectionService.select(currencyID: currency.id, for: side) else { return }
        
        rebuildState()
    }
    
    func makeGraphResult() -> TradingRunResult? {
        tradingResult
    }
}

// MARK: - Private Methods
private extension BotViewModel {
    var isCurrencySet: Bool {
        currencySelectionService.selectedCurrencyID(for: .left) != nil
        && currencySelectionService.selectedCurrencyID(for: .right) != nil
    }
    
    func makeAmountText(title: String, value: Float) -> String {
        "\(title)\(AppConfiguration.PriceFormatting.string(from: value))"
    }
    
    func rebuildState() {
        if let tradingResult {
            viewState = makeResultState(from: tradingResult)
        } else {
            viewState = makeInitialState()
        }
    }
    
    func makeInitialState() -> ViewState {
        let operationCells = makeOperationCells(from: operations)
        
        return ViewState(
            balanceText: makeAmountText(title: Constants.balanceTitle, value: startBalance),
            profitText: makeAmountText(title: Constants.profitTitle, value: .zero),
            balanceTone: .neutral,
            profitTone: .neutral,
            operations: operationCells,
            isWarningHidden: false,
            isTableHidden: true,
            leftCurrencyText: selectedCurrencyText(for: .left),
            rightCurrencyText: selectedCurrencyText(for: .right)
        )
    }
    
    func makeResultState(from tradingResult: TradingRunResult) -> ViewState {
        let operationCells = makeOperationCells(from: operations)
        
        return ViewState(
            balanceText: makeAmountText(title: Constants.balanceTitle, value: tradingResult.finalBalance),
            profitText: makeAmountText(title: Constants.profitTitle, value: tradingResult.finalProfit),
            balanceTone: tradingResult.finalBalance < startBalance ? .negative : .positive,
            profitTone: tradingResult.finalProfit < .zero ? .negative : .positive,
            operations: operationCells,
            isWarningHidden: true,
            isTableHidden: false,
            leftCurrencyText: selectedCurrencyText(for: .left),
            rightCurrencyText: selectedCurrencyText(for: .right)
        )
    }
    
    func selectedCurrencyText(for side: SelectedSide) -> String {
        guard let currencyID = currencySelectionService.selectedCurrencyID(for: side),
              let currency = currencyRepository.getCurrency(id: currencyID) else {
            return Constants.defaultCurrencyText
        }
        
        return currency.code
    }
    
    private func makeRandomOperationType() -> OperationType {
        [.buy, .sell, .ignore].randomElement() ?? .ignore
    }
    
    private func addNextOperation() {
        let operationType = makeRandomOperationType()
        let price = Float.random(in: Constants.priceRange)
        
        let snapshot = MarketSnapshot(
            currentPrice: price,
            buyOrders: Int.random(in: Constants.ordersRange),
            sellOrders: Int.random(in: Constants.ordersRange)
        )

        let operation = Operation(
            id: UUID(),
            operationType: operationType,
            snapshot: snapshot,
            startPrice: nil,
            income: nil
        )
        
        operations.append(operation)
        
        tradingResult = TradingRunResult(
            cycles: operations.count,
            finalBalance: tradingResult?.finalBalance ?? startBalance,
            finalProfit: tradingResult?.finalProfit ?? .zero,
            operations: operations,
            candlesticks: CandlestickFactory.makeCandlesticks(from: operations),
            lineChartPoints: LinesFactory.makeLinePoints(from: operations)
        )

        rebuildState()
        
        onStateChange?(viewState)
        onTradingResultChange?(tradingResult)
    }
    
    func makeOperationCells(from operations: [Operation]) -> [OperationCellViewModel] {
        operations.map {
            OperationCellViewModel(
                text: operationFormatter.makeText(for: $0),
                operationType: $0.operationType
            )
        }
    }
}

// MARK: - Timer
private extension BotViewModel {
    func startLiveUpdates() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.addNextOperation()
        }
    }
    
    func stopLiveUpdates() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Constants
private extension BotViewModel {
    enum Constants {
        static let emptyText = ""
        static let balanceTitle = "Balance: "
        static let profitTitle = "Profit: "
        static let defaultCurrencyText = "Choose"
        static let priceRange: ClosedRange<Float> = 80...150
        static let ordersRange: ClosedRange<Int> = 100...900
    }
}
