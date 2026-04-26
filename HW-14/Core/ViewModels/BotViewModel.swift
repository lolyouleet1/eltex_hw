import Foundation

final class BotViewModel {
    // MARK: - Models
    struct ViewState {
        let results: [BotResultCellViewModel]
        let isWarningHidden: Bool
        let isTableHidden: Bool
        let isStartButtonEnabled: Bool
        let warningText: String
        let leftCurrencyText: String
        let rightCurrencyText: String
        let botLimitText: String
        let startButtonTitle: String
    }
    
    // MARK: - Dependencies
    private let tradingRunService: TradingRunService
    private let operationFormatter: OperationFormatter
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencySelectionService: CurrencySelectionService
    private let tradeBotNameProvider: TradeBotNameProvider
    
    // MARK: - State
    private var resultCells: [BotResultCellViewModel] = []
    private var botsAmountText = Constants.emptyText
    private var isRunInProgress = false
    private(set) var viewState: ViewState
    var onStateChange: ((ViewState) -> Void)?
    
    // MARK: - Lifecycle
    init(tradingRunService: TradingRunService, operationFormatter: OperationFormatter, currencyRepository: CurrencyRepositoryProtocol, currencySelectionService: CurrencySelectionService, tradeBotNameProvider: TradeBotNameProvider) {
        self.tradingRunService = tradingRunService
        self.operationFormatter = operationFormatter
        self.currencyRepository = currencyRepository
        self.currencySelectionService = currencySelectionService
        self.tradeBotNameProvider = tradeBotNameProvider
        self.viewState = ViewState(
            results: [],
            isWarningHidden: false,
            isTableHidden: true,
            isStartButtonEnabled: true,
            warningText: Constants.defaultWarningText,
            leftCurrencyText: Constants.defaultCurrencyText,
            rightCurrencyText: Constants.defaultCurrencyText,
            botLimitText: Constants.emptyText,
            startButtonTitle: Constants.startButtonTitle
        )
        
        rebuildState()
    }
    
    // MARK: - Public Methods
    func handleStart(botsAmount: String?, isBotEnabled: Bool) {
        botsAmountText = botsAmount?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Constants.emptyText
        guard !isBotsAmountInvalid else {
            rebuildState()
            onStateChange?(viewState)
            return
        }
        guard !isRunInProgress else { return }
        guard let numberOfBotsString = botsAmountText.nilIfEmpty,
              let numberOfBots = Int(numberOfBotsString),
              numberOfBots > .zero else { return }
        guard isBotEnabled, isCurrencySet else { return }
        
        let bots = createBots(arraySize: numberOfBots)
        guard let pair = bots.first?.pair else { return }
        
        isRunInProgress = true
        rebuildState()
        onStateChange?(viewState)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            let results = tradingRunService.runBots(bots: bots)
            let snapshot = tradingRunService.walletSnapshot()
            
            DispatchQueue.main.async {
                self.resultCells = self.makeResultCells(
                    from: results,
                    snapshot: snapshot,
                    pair: pair,
                    botsCount: bots.count
                )
                self.isRunInProgress = false
                self.rebuildState()
                self.onStateChange?(self.viewState)
            }
        }
    }
    
    func handleBotsAmountChange(_ botsAmount: String?) {
        botsAmountText = botsAmount?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Constants.emptyText
        rebuildState()
        
        onStateChange?(viewState)
    }
    
    func handleClear() {
        resultCells.removeAll()
        rebuildState()
        
        onStateChange?(viewState)
    }
    
    func handleRandomCurrencies() {
        _ = currencySelectionService.selectRandomPair(from: currencyRepository.getCurrencies())
        rebuildState()
    }
    
    func handleCurrencySelection(_ currency: Currency, for side: SelectedSide) {
        guard currencySelectionService.select(currencyID: currency.id, for: side) else { return }
        
        rebuildState()
    }
}

// MARK: - Private Methods
private extension BotViewModel {
    var isBotsAmountInvalid: Bool {
        guard let botsAmount = Int(botsAmountText) else { return false }
        
        return botsAmount > tradeBotNameProvider.maxNamesCount
    }
    
    var isCurrencySet: Bool {
        currencySelectionService.selectedCurrencyID(for: .left) != nil
        && currencySelectionService.selectedCurrencyID(for: .right) != nil
    }
    
    func rebuildState() {
        viewState = ViewState(
            results: resultCells,
            isWarningHidden: isWarningHidden,
            isTableHidden: resultCells.isEmpty,
            isStartButtonEnabled: !isRunInProgress && !isBotsAmountInvalid,
            warningText: warningText,
            leftCurrencyText: selectedCurrencyText(for: .left),
            rightCurrencyText: selectedCurrencyText(for: .right),
            botLimitText: makeBotLimitText(maxBotsCount: tradeBotNameProvider.maxNamesCount),
            startButtonTitle: isRunInProgress ? Constants.runningButtonTitle : Constants.startButtonTitle
        )
    }
    
    var isWarningHidden: Bool {
        !isBotsAmountInvalid && !resultCells.isEmpty
    }
    
    var warningText: String {
        isBotsAmountInvalid ? Constants.notEnoughBotsWarningText : Constants.defaultWarningText
    }
    
    func selectedCurrencyText(for side: SelectedSide) -> String {
        guard let currencyID = currencySelectionService.selectedCurrencyID(for: side),
              let currency = currencyRepository.getCurrency(id: currencyID) else {
            return Constants.defaultCurrencyText
        }
        
        return currency.code
    }
    
    func makeResultCells(from results: [BotDayResult], snapshot: WalletSnapshot, pair: CurrencyPair, botsCount: Int) -> [BotResultCellViewModel] {
        var cells = results.map {
            BotResultCellViewModel(
                text: operationFormatter.makeTextForBot(for: $0),
                tone: makeTone(from: $0.income)
            )
        }
        
        cells.append(
            BotResultCellViewModel(
                text: operationFormatter.makeRunSummaryText(
                    botsCount: botsCount,
                    daysCount: AppConfiguration.TradeBotSettings.workingDays,
                    rowsCount: results.count
                ),
                tone: .neutral
            )
        )
        
        let incomesByCurrency = Dictionary(grouping: results, by: \.incomeCurrencyCode)
        let sortedIncomeCurrencies = incomesByCurrency.keys.sorted()
        
        for currencyCode in sortedIncomeCurrencies {
            let totalIncome = incomesByCurrency[currencyCode]?.reduce(.zero) {
                $0 + $1.income
            } ?? .zero
            
            cells.append(
                BotResultCellViewModel(
                    text: operationFormatter.makeTotalIncomeText(
                        currencyCode: currencyCode,
                        income: totalIncome
                    ),
                    tone: makeTone(from: totalIncome)
                )
            )
        }
        
        let pairCodes = [pair.base.code, pair.quote.code]
        let balanceItems = snapshot.items
            .filter { pairCodes.contains($0.currencyCode) }
            .sorted { $0.currencyCode < $1.currencyCode }
        
        for item in balanceItems {
            cells.append(
                BotResultCellViewModel(
                    text: operationFormatter.makeWalletBalanceText(for: item),
                    tone: .neutral
                )
            )
        }
        
        return cells
    }
    
    func makeTone(from income: Float) -> ResultTone {
        income >= .zero ? .positive : .negative
    }
    
    func createBots(arraySize: Int) -> [WalletBot] {
        guard let leftCurrencyID = currencySelectionService.leftCurrencyID,
              let rightCurrencyID = currencySelectionService.rightCurrencyID,
              let leftCurrency = currencyRepository.getCurrency(id: leftCurrencyID),
              let rightCurrency = currencyRepository.getCurrency(id: rightCurrencyID) else {
            return []
        }
        
        tradeBotNameProvider.reset()
        
        return (0..<arraySize).compactMap { _ in
            guard let name = tradeBotNameProvider.getRandomName() else { return nil }
            
            return WalletBot(
                name: name,
                pair: CurrencyPair(base: leftCurrency, quote: rightCurrency)
            )
        }
    }
    
    func makeBotLimitText(maxBotsCount: Int) -> String {
        "\(Constants.botLimitTitle)\(maxBotsCount)"
    }
}

// MARK: - Constants
private extension BotViewModel {
    enum Constants {
        static let defaultCurrencyText = "Choose"
        static let startButtonTitle = "START BOT"
        static let runningButtonTitle = "RUNNING..."
        static let botLimitTitle = "Number of bots available: "
        static let defaultWarningText = "WARNING: not enough data"
        static let notEnoughBotsWarningText = "WARNING: not enough bots"
        static let emptyText = ""
    }
}

// MARK: - Helpers
private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
