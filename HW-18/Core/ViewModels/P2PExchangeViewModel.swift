import Foundation

final class P2PExchangeViewModel {
    // MARK: - Models
    struct ViewState {
        let offers: [P2POfferCellViewModel]
        let isTableHidden: Bool
        let isLoading: Bool
        let emptyStateText: String
        let leftCurrencyText: String
        let rightCurrencyText: String
        let sendBalanceText: String
        let receiveBalanceText: String
    }
    
    enum State {
        case idle
        case loading([P2POffer])
        case loaded([P2POffer])
        case empty(EmptyReason)
    }
    
    enum EmptyReason {
        case currencyPair
        case offers
    }
    
    // MARK: - Dependencies
    private let exchangeUseCase: P2PExchangeUseCaseProtocol
    private let currencySelectionService: CurrencySelectionService
    
    // MARK: - State
    private var apiCurrencies: [Currency] = []
    private var selectedSendCurrency: Currency?
    private var selectedReceiveCurrency: Currency?
    private var state: State = .idle
    private var didStart = false
    
    private(set) var viewState: ViewState
    var onStateChange: ((ViewState) -> Void)?
    var onAlert: ((P2PAlertViewModel) -> Void)?
    
    // MARK: - Lifecycle
    init(
        exchangeUseCase: P2PExchangeUseCaseProtocol,
        currencySelectionService: CurrencySelectionService
    ) {
        self.exchangeUseCase = exchangeUseCase
        self.currencySelectionService = currencySelectionService
        self.viewState = ViewState(
            offers: [],
            isTableHidden: true,
            isLoading: false,
            emptyStateText: Constants.defaultEmptyStateText,
            leftCurrencyText: Constants.defaultCurrencyText,
            rightCurrencyText: Constants.defaultCurrencyText,
            sendBalanceText: Constants.defaultSendBalanceText,
            receiveBalanceText: Constants.defaultReceiveBalanceText
        )
        
        rebuildState()
    }
    
    // MARK: - Public Methods
    func start() {
        guard !didStart else { return }
        
        didStart = true
        state = .loading([])
        publishState()
        
        exchangeUseCase.loadCurrencies { [weak self] result in
            DispatchQueue.main.async {
                self?.handleCurrenciesResult(result)
            }
        }
    }
    
    func availableCurrencies() -> [Currency] {
        apiCurrencies
    }
    
    func offer(at index: Int) -> P2POffer? {
        guard offers.indices.contains(index) else { return nil }
        
        return offers[index]
    }
    
    func handleCurrencySelection(_ currency: Currency, for side: SelectedSide) {
        switch side {
        case .left:
            guard selectedReceiveCurrency?.id != currency.id,
                  currencySelectionService.select(currencyID: currency.id, for: side) else { return }
            
            selectedSendCurrency = currency
        case .right:
            guard selectedSendCurrency?.id != currency.id,
                  currencySelectionService.select(currencyID: currency.id, for: side) else { return }
            
            selectedReceiveCurrency = currency
        }
        
        loadOffers()
    }
    
    func exchangeInputViewModel(for index: Int) -> P2PExchangeInputViewModel? {
        guard let offer = offer(at: index),
              let sendCurrency = selectedSendCurrency,
              let receiveCurrency = selectedReceiveCurrency else {
            return nil
        }
        
        let rateText = AppConfiguration.PriceFormatting.string(from: offer.rate)
        
        return P2PExchangeInputViewModel(
            title: "\(Constants.exchangeTitle)\(Constants.textSeparator)\(offer.sellerName)",
            message: "\(Constants.rateTitle)\(sendCurrency.code)\(Constants.rateSeparator)\(receiveCurrency.code)\(Constants.valueSeparator)\(rateText)",
            placeholder: "\(Constants.amountPlaceholder)\(Constants.textSeparator)\(sendCurrency.code)",
            actionTitle: Constants.executeButtonTitle,
            cancelTitle: Constants.cancelButtonTitle
        )
    }
    
    func performExchange(offerIndex: Int, amountText: String?) {
        guard let offer = offer(at: offerIndex),
              let sendCurrency = selectedSendCurrency,
              let receiveCurrency = selectedReceiveCurrency else {
            showAlert(for: P2PExchangeError.operationFailed)
            return
        }
        
        state = .loading(offers)
        publishState()
        
        exchangeUseCase.performExchange(
            offer: offer,
            sendCurrency: sendCurrency,
            receiveCurrency: receiveCurrency,
            amountText: amountText
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleExchangeResult(result)
            }
        }
    }
}

// MARK: - Private Methods
private extension P2PExchangeViewModel {
    func handleCurrenciesResult(_ result: Result<[Currency], NetworkError>) {
        switch result {
        case .success(let currencies):
            apiCurrencies = currencies
            selectDefaultPair()
            loadOffers()
        case .failure(let error):
            apiCurrencies.removeAll()
            selectedSendCurrency = nil
            selectedReceiveCurrency = nil
            state = .empty(.currencyPair)
            publishState()
            showAlert(for: error)
        }
    }
    
    func handleOffersResult(_ result: Result<[P2POffer], NetworkError>) {
        switch result {
        case .success(let offers):
            state = makeState(from: offers)
            publishState()
        case .failure(let error):
            state = .empty(.offers)
            publishState()
            showAlert(for: error)
        }
    }
    
    func handleExchangeResult(_ result: Result<P2PExchangeResult, P2PExchangeError>) {
        let currentOffers = offers
        state = makeState(from: currentOffers)
        publishState()
        
        switch result {
        case .success(let result):
            showSuccessAlert(result)
        case .failure(let error):
            showAlert(for: error)
        }
    }
    
    func loadOffers() {
        guard let sendCurrency = selectedSendCurrency,
              let receiveCurrency = selectedReceiveCurrency else {
            state = .empty(.currencyPair)
            publishState()
            return
        }
        
        state = .loading([])
        publishState()
        
        exchangeUseCase.loadOffers(
            sendCurrency: sendCurrency,
            receiveCurrency: receiveCurrency
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleOffersResult(result)
            }
        }
    }
    
    func selectDefaultPair() {
        guard !apiCurrencies.isEmpty else { return }
        
        let sendCurrency = currency(with: Constants.defaultSendCurrencyCode) ?? apiCurrencies.first
        let fallbackReceiveCurrency = apiCurrencies.first { $0.id != sendCurrency?.id }
        let receiveCurrency = currency(with: Constants.defaultReceiveCurrencyCode) ?? fallbackReceiveCurrency
        
        guard let sendCurrency,
              let receiveCurrency,
              sendCurrency.id != receiveCurrency.id else {
            return
        }
        
        selectedSendCurrency = sendCurrency
        selectedReceiveCurrency = receiveCurrency
        _ = currencySelectionService.selectPair(
            leftCurrencyID: sendCurrency.id,
            rightCurrencyID: receiveCurrency.id
        )
    }
    
    func currency(with code: String) -> Currency? {
        apiCurrencies.first { $0.code == code }
    }
    
    func publishState() {
        rebuildState()
        onStateChange?(viewState)
    }
    
    func rebuildState() {
        let offerCells = offers.map {
            P2POfferCellViewModel(
                sellerText: $0.sellerName,
                rateText: makeRateText(for: $0),
                reserveText: makeReserveText(for: $0)
            )
        }
        
        viewState = ViewState(
            offers: offerCells,
            isTableHidden: offerCells.isEmpty,
            isLoading: isLoading,
            emptyStateText: emptyStateText,
            leftCurrencyText: selectedSendCurrency?.code ?? Constants.defaultCurrencyText,
            rightCurrencyText: selectedReceiveCurrency?.code ?? Constants.defaultCurrencyText,
            sendBalanceText: makeBalanceText(for: selectedSendCurrency, title: Constants.sendBalanceTitle),
            receiveBalanceText: makeBalanceText(for: selectedReceiveCurrency, title: Constants.receiveBalanceTitle)
        )
    }
    
    func makeState(from offers: [P2POffer]) -> State {
        offers.isEmpty ? .empty(.offers) : .loaded(offers)
    }
    
    var offers: [P2POffer] {
        switch state {
        case .loading(let offers), .loaded(let offers):
            return offers
        case .idle, .empty:
            return []
        }
    }
    
    var isLoading: Bool {
        if case .loading = state {
            return true
        }
        
        return false
    }
    
    var emptyStateText: String {
        switch state {
        case .loading:
            return Constants.loadingText
        case .idle, .empty(.currencyPair):
            return Constants.defaultEmptyStateText
        case .loaded, .empty(.offers):
            return Constants.noOffersText
        }
    }
    
    func makeRateText(for offer: P2POffer) -> String {
        let rate = AppConfiguration.PriceFormatting.string(from: offer.rate)
        
        return "\(Constants.rateTitle)\(rate)\(Constants.textSeparator)\(offer.receiveCurrencyCode)"
    }
    
    func makeReserveText(for offer: P2POffer) -> String {
        let reserve = AppConfiguration.PriceFormatting.string(from: offer.reserve)
        
        return "\(Constants.reserveCellTitle)\(reserve)\(Constants.textSeparator)\(offer.receiveCurrencyCode)"
    }
    
    func makeBalanceText(for currency: Currency?, title: String) -> String {
        guard let currency else {
            return title + Constants.emptyBalanceText
        }
        
        let balance = AppConfiguration.PriceFormatting.string(
            from: exchangeUseCase.balance(for: currency.code)
        )
        
        return "\(title)\(balance)\(Constants.textSeparator)\(currency.code)"
    }
    
    func showAlert(for error: P2PExchangeError) {
        switch error {
        case .invalidAmount:
            showValidationAlert(title: Constants.invalidAmountTitle, message: Constants.invalidAmountMessage)
        case .notEnoughMoney:
            showValidationAlert(title: Constants.notEnoughMoneyTitle, message: Constants.notEnoughMoneyMessage)
        case .reserveIsTooLow:
            showValidationAlert(title: Constants.reserveTitle, message: Constants.reserveMessage)
        case .network(let error):
            showAlert(for: error)
        case .operationFailed:
            showValidationAlert(title: Constants.operationFailedTitle, message: Constants.operationFailedMessage)
        }
    }
    
    func showAlert(for error: NetworkError) {
        switch error {
        case .noInternet:
            showValidationAlert(title: Constants.noInternetTitle, message: Constants.noInternetMessage)
        case .serviceUnavailable:
            showValidationAlert(title: Constants.serviceUnavailableTitle, message: Constants.serviceUnavailableMessage)
        case .parsingFailed:
            showValidationAlert(title: Constants.parsingTitle, message: Constants.parsingMessage)
        case .accessDenied:
            showValidationAlert(title: Constants.accessDeniedTitle, message: Constants.accessDeniedMessage)
        default:
            showValidationAlert(title: Constants.operationFailedTitle, message: Constants.operationFailedMessage)
        }
    }
    
    func showValidationAlert(title: String, message: String) {
        onAlert?(
            P2PAlertViewModel(
                title: title,
                message: message
            )
        )
    }
    
    func showSuccessAlert(_ result: P2PExchangeResult) {
        let sendAmount = AppConfiguration.PriceFormatting.string(from: result.sendAmount)
        let receiveAmount = AppConfiguration.PriceFormatting.string(from: result.receiveAmount)
        let message = "\(Constants.sentTitle)\(sendAmount)\(Constants.textSeparator)\(result.sendCurrencyCode)\(Constants.lineSeparator)\(Constants.receivedTitle)\(receiveAmount)\(Constants.textSeparator)\(result.receiveCurrencyCode)"
        
        showValidationAlert(title: Constants.successTitle, message: message)
    }
}

// MARK: - Constants
private extension P2PExchangeViewModel {
    enum Constants {
        static let defaultCurrencyText = "Choose"
        static let defaultEmptyStateText = "Choose currency pair"
        static let defaultSendBalanceText = "Send balance: -"
        static let defaultReceiveBalanceText = "Receive balance: -"
        static let sendBalanceTitle = "Send balance: "
        static let receiveBalanceTitle = "Receive balance: "
        static let emptyBalanceText = "-"
        static let defaultSendCurrencyCode = "EUR"
        static let defaultReceiveCurrencyCode = "USD"
        static let loadingText = "Loading offers..."
        static let noOffersText = "No offers"
        static let rateTitle = "Rate: "
        static let reserveCellTitle = "Reserve: "
        static let rateSeparator = " to "
        static let valueSeparator = ": "
        static let textSeparator = " "
        static let lineSeparator = "\n"
        static let exchangeTitle = "Exchange with"
        static let amountPlaceholder = "Amount in"
        static let executeButtonTitle = "Execute"
        static let cancelButtonTitle = "Cancel"
        static let invalidAmountTitle = "Invalid amount"
        static let invalidAmountMessage = "Enter an amount greater than zero."
        static let notEnoughMoneyTitle = "Not enough balance"
        static let notEnoughMoneyMessage = "There is not enough money in your wallet for this exchange."
        static let reserveTitle = "Reserve is too low"
        static let reserveMessage = "The seller does not have enough reserve for this amount."
        static let noInternetTitle = "No internet connection"
        static let noInternetMessage = "Check your connection and try again."
        static let serviceUnavailableTitle = "Service is unavailable"
        static let serviceUnavailableMessage = "FloatRates API is not responding. Please try again later."
        static let parsingTitle = "Something went wrong"
        static let parsingMessage = "Please try again later."
        static let accessDeniedTitle = "Access denied"
        static let accessDeniedMessage = "You do not have permission to view this section."
        static let operationFailedTitle = "Operation failed"
        static let operationFailedMessage = "The exchange was not completed. Please try again."
        static let successTitle = "Exchange completed"
        static let sentTitle = "Sent: "
        static let receivedTitle = "Received: "
    }
}
