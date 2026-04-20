import Foundation

final class CurrenciesViewModel {
    struct LabelState {
        let text: String
        let appearance: CurrencyLabelAppearance
    }
    
    struct ViewState {
        let items: [CurrencyItemViewModel]
        let leftLabelState: LabelState
        let rightLabelState: LabelState
        let activeFilter: FilterType
        let exchangeRateText: String
        let timerText: String
        let emptyStateMessage: String?
    }
    
    enum CurrencyLabelAppearance {
        case normal
        case attentionPrimary
        case attentionSecondary
    }
    
    // MARK: - Dependencies
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyFilterService: CurrencyFilterService
    private let currencySelectionService: CurrencySelectionService
    private let currencyRateService: CurrencyRateService
    
    // MARK: - State
    private var activeFilter: FilterType = .all
    private var isFavoritesOnlyEnabled = false
    private var pendingSelectionSide: SelectedSide?
    private var isPrimaryBlinkState = true
    private var blinkingTimer: Timer?
    private var exchangeRateTimer: Timer?
    private var updateCountdown = Constants.exchangeRateRefreshPeriod
    
    private(set) var viewState: ViewState
    var onStateChange: ((ViewState) -> Void)?
    
    // MARK: - Lifecycle
    init(currencyRepository: CurrencyRepositoryProtocol, currencyFilterService: CurrencyFilterService, currencySelectionService: CurrencySelectionService, currencyRateService: CurrencyRateService) {
        self.currencyRepository = currencyRepository
        self.currencyFilterService = currencyFilterService
        self.currencySelectionService = currencySelectionService
        self.currencyRateService = currencyRateService
        self.viewState = ViewState(
            items: [],
            leftLabelState: LabelState(text: Constants.emptyText, appearance: .normal),
            rightLabelState: LabelState(text: Constants.emptyText, appearance: .normal),
            activeFilter: .all,
            exchangeRateText: Constants.defaultExchangeRateText,
            timerText: "\(Constants.timerTitle)\(Constants.exchangeRateRefreshPeriod)",
            emptyStateMessage: nil
        )
        
        rebuildState()
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Public Methods
    func start() {
        guard exchangeRateTimer == nil else {
            publishState()
            return
        }
        
        exchangeRateTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.exchangeRateTimerInterval,
            repeats: true
        ) { [weak self] _ in
            self?.handleExchangeRateTimerTick()
        }
        
        publishState()
    }
    
    func stop() {
        exchangeRateTimer?.invalidate()
        exchangeRateTimer = nil
        
        blinkingTimer?.invalidate()
        blinkingTimer = nil
    }
    
    func handleCurrencyLabelTap(_ side: SelectedSide) {
        guard pendingSelectionSide == nil else { return }
        
        pendingSelectionSide = side
        isPrimaryBlinkState = true
        
        startBlinkingTimer()
        publishState()
    }
    
    func handleCurrencySelection(at index: Int) {
        guard let pendingSelectionSide,
              viewState.items.indices.contains(index) else { return }
        
        let currencyID = viewState.items[index].id
        guard currencySelectionService.select(currencyID: currencyID, for: pendingSelectionSide) else { return }
        
        self.pendingSelectionSide = nil
        stopBlinkingTimer()
        publishState()
    }
    
    func handleFilterSelection(_ filter: FilterType) {
        activeFilter = filter
        publishState()
    }
    
    func handleFavoritesToggle(isOn: Bool) {
        isFavoritesOnlyEnabled = isOn
        publishState()
    }
    
    func handleFavoriteToggle(at index: Int) {
        guard viewState.items.indices.contains(index) else { return }
        
        let currencyID = viewState.items[index].id
        currencyRepository.toggleFavorite(currencyID: currencyID)
        publishState()
    }
}

// MARK: - Private Methods
private extension CurrenciesViewModel {
    func handleExchangeRateTimerTick() {
        if updateCountdown == Constants.minimumCountdownValue {
            currencyRepository.updateBaseValues()
            updateCountdown = Constants.exchangeRateRefreshPeriod
        } else {
            updateCountdown -= 1
        }
        
        publishState()
    }
    
    func startBlinkingTimer() {
        stopBlinkingTimer()
        
        blinkingTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.blinkingInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            
            self.isPrimaryBlinkState.toggle()
            self.publishState()
        }
    }
    
    func stopBlinkingTimer() {
        blinkingTimer?.invalidate()
        blinkingTimer = nil
        isPrimaryBlinkState = true
    }
    
    func publishState() {
        rebuildState()
        onStateChange?(viewState)
    }
    
    func rebuildState() {
        let currencies = currencyFilterService.makeCurrencies(
            from: currencyRepository.getCurrencies(),
            typeFilter: activeFilter,
            favoritesOnly: isFavoritesOnlyEnabled
        )
        
        let items = makeItems(from: currencies)
        viewState = ViewState(
            items: items,
            leftLabelState: makeLabelState(for: .left),
            rightLabelState: makeLabelState(for: .right),
            activeFilter: activeFilter,
            exchangeRateText: makeExchangeRateText(),
            timerText: "\(Constants.timerTitle)\(updateCountdown)",
            emptyStateMessage: makeEmptyStateMessage(for: items)
        )
    }
    
    func makeItems(from currencies: [Currency]) -> [CurrencyItemViewModel] {
        currencies.map {
            CurrencyItemViewModel(
                id: $0.id,
                title: $0.code,
                isFavorite: $0.isFavorite,
                selectionState: currencySelectionService.selectionState(for: $0.id)
            )
        }
    }
    
    func makeLabelState(for side: SelectedSide) -> LabelState {
        if pendingSelectionSide == side {
            return LabelState(
                text: Constants.chooseCurrencyText,
                appearance: isPrimaryBlinkState ? .attentionPrimary : .attentionSecondary
            )
        }
        
        guard let currency = selectedCurrency(for: side) else {
            return LabelState(text: Constants.emptyText, appearance: .normal)
        }
        
        return LabelState(text: currency.code, appearance: .normal)
    }
    
    func makeExchangeRateText() -> String {
        guard let leftCurrency = selectedCurrency(for: .left),
              let rightCurrency = selectedCurrency(for: .right) else {
            return Constants.defaultExchangeRateText
        }
        
        let exchangeRate = currencyRateService.exchangeRate(from: leftCurrency, to: rightCurrency)
        let exchangeRateText = AppConfiguration.PriceFormatting.string(from: exchangeRate)
        
        return "\(Constants.rateTitle)\(leftCurrency.code)\(Constants.rateSeparator)\(rightCurrency.code): \(exchangeRateText)"
    }
    
    func makeEmptyStateMessage(for items: [CurrencyItemViewModel]) -> String? {
        if isFavoritesOnlyEnabled && items.isEmpty {
            return Constants.emptyFavoritesText
        }
        
        return nil
    }
    
    func selectedCurrency(for side: SelectedSide) -> Currency? {
        guard let currencyID = currencySelectionService.selectedCurrencyID(for: side) else {
            return nil
        }
        
        return currencyRepository.getCurrency(id: currencyID)
    }
}

// MARK: - Constants
private extension CurrenciesViewModel {
    enum Constants {
        static let emptyText = ""
        static let chooseCurrencyText = "Choose Currency"
        static let defaultExchangeRateText = "Rate left to right:"
        static let rateTitle = "Rate "
        static let rateSeparator = " to "
        static let timerTitle = "Update in: "
        static let emptyFavoritesText = "No favorite currencies"
        static let minimumCountdownValue = 1
        static let blinkingInterval: TimeInterval = 0.35
        static let exchangeRateTimerInterval: TimeInterval = 1
        static let exchangeRateRefreshPeriod: Int = 5
    }
}
