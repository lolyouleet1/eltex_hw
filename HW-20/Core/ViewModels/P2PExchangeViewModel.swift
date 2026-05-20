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
    private let logger: AppLoggerProtocol
    
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
        currencySelectionService: CurrencySelectionService,
        logger: AppLoggerProtocol = AppLogger.p2pTrading
    ) {
        self.exchangeUseCase = exchangeUseCase
        self.currencySelectionService = currencySelectionService
        self.logger = logger
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
        guard !didStart else {
            logger.info(
                Constants.startSkippedMessage,
                metadata: [
                    AppLogMetadataKey.reason: Constants.alreadyStartedReason
                ]
            )
            return
        }
        
        didStart = true
        logger.info(Constants.currencyLoadingStartedMessage)
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
        guard offers.indices.contains(index) else {
            logger.warning(
                Constants.offerRequestRejectedMessage,
                metadata: [
                    AppLogMetadataKey.reason: Constants.invalidOfferIndexReason
                ]
            )
            return nil
        }
        
        return offers[index]
    }
    
    func handleCurrencySelection(_ currency: Currency, for side: SelectedSide) {
        switch side {
        case .left:
            guard selectedReceiveCurrency?.id != currency.id,
                  currencySelectionService.select(currencyID: currency.id, for: side) else {
                logCurrencySelectionRejected(currency, side: side)
                return
            }
            
            selectedSendCurrency = currency
        case .right:
            guard selectedSendCurrency?.id != currency.id,
                  currencySelectionService.select(currencyID: currency.id, for: side) else {
                logCurrencySelectionRejected(currency, side: side)
                return
            }
            
            selectedReceiveCurrency = currency
        }
        
        logger.info(
            Constants.currencySelectionCompletedMessage,
            metadata: [
                AppLogMetadataKey.baseCurrency: selectedSendCurrency?.code ?? Constants.emptyMetadataValue,
                AppLogMetadataKey.quoteCurrency: selectedReceiveCurrency?.code ?? Constants.emptyMetadataValue,
                AppLogMetadataKey.side: side.logDescription
            ]
        )
        loadOffers()
    }
    
    func exchangeInputViewModel(for index: Int) -> P2PExchangeInputViewModel? {
        guard let offer = offer(at: index),
              let sendCurrency = selectedSendCurrency,
              let receiveCurrency = selectedReceiveCurrency else {
            logger.warning(
                Constants.exchangeInputRejectedMessage,
                metadata: [
                    AppLogMetadataKey.reason: Constants.missingExchangeDataReason
                ]
            )
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
            logger.error(
                Constants.exchangeRejectedMessage,
                metadata: [
                    AppLogMetadataKey.error: P2PExchangeError.operationFailed.logDescription,
                    AppLogMetadataKey.reason: Constants.missingExchangeDataReason
                ]
            )
            showAlert(for: P2PExchangeError.operationFailed)
            return
        }
        
        logger.info(
            Constants.exchangeStartedMessage,
            metadata: [
                AppLogMetadataKey.offerID: offer.id.uuidString,
                AppLogMetadataKey.sendCurrency: sendCurrency.code,
                AppLogMetadataKey.receiveCurrency: receiveCurrency.code
            ]
        )
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
            logger.info(
                Constants.currencyLoadingCompletedMessage,
                metadata: [
                    AppLogMetadataKey.count: String(currencies.count)
                ]
            )
            apiCurrencies = currencies
            selectDefaultPair()
            loadOffers()
        case .failure(let error):
            logger.error(
                Constants.currencyLoadingFailedMessage,
                metadata: [
                    AppLogMetadataKey.error: error.logDescription
                ]
            )
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
            logger.info(
                Constants.offerLoadingCompletedMessage,
                metadata: [
                    AppLogMetadataKey.count: String(offers.count)
                ]
            )
            state = makeState(from: offers)
            publishState()
        case .failure(let error):
            logger.error(
                Constants.offerLoadingFailedMessage,
                metadata: [
                    AppLogMetadataKey.error: error.logDescription
                ]
            )
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
            logger.info(
                Constants.exchangeCompletedMessage,
                metadata: [
                    AppLogMetadataKey.sendAmount: AppConfiguration.PriceFormatting.string(from: result.sendAmount),
                    AppLogMetadataKey.sendCurrency: result.sendCurrencyCode,
                    AppLogMetadataKey.receiveAmount: AppConfiguration.PriceFormatting.string(from: result.receiveAmount),
                    AppLogMetadataKey.receiveCurrency: result.receiveCurrencyCode
                ]
            )
            showSuccessAlert(result)
        case .failure(let error):
            logger.error(
                Constants.exchangeFailedMessage,
                metadata: [
                    AppLogMetadataKey.error: error.logDescription
                ]
            )
            showAlert(for: error)
        }
    }
    
    func loadOffers() {
        guard let sendCurrency = selectedSendCurrency,
              let receiveCurrency = selectedReceiveCurrency else {
            logger.warning(
                Constants.offerLoadingRejectedMessage,
                metadata: [
                    AppLogMetadataKey.reason: Constants.missingCurrencyPairReason
                ]
            )
            state = .empty(.currencyPair)
            publishState()
            return
        }
        
        logger.info(
            Constants.offerLoadingStartedMessage,
            metadata: [
                AppLogMetadataKey.baseCurrency: sendCurrency.code,
                AppLogMetadataKey.quoteCurrency: receiveCurrency.code
            ]
        )
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
        guard !apiCurrencies.isEmpty else {
            logger.warning(
                Constants.defaultPairSelectionRejectedMessage,
                metadata: [
                    AppLogMetadataKey.reason: Constants.emptyCurrenciesReason
                ]
            )
            return
        }
        
        let sendCurrency = currency(with: Constants.defaultSendCurrencyCode) ?? apiCurrencies.first
        let fallbackReceiveCurrency = apiCurrencies.first { $0.id != sendCurrency?.id }
        let receiveCurrency = currency(with: Constants.defaultReceiveCurrencyCode) ?? fallbackReceiveCurrency
        
        guard let sendCurrency,
              let receiveCurrency,
              sendCurrency.id != receiveCurrency.id else {
            logger.warning(
                Constants.defaultPairSelectionRejectedMessage,
                metadata: [
                    AppLogMetadataKey.reason: Constants.invalidCurrencyPairReason
                ]
            )
            return
        }
        
        selectedSendCurrency = sendCurrency
        selectedReceiveCurrency = receiveCurrency
        _ = currencySelectionService.selectPair(
            leftCurrencyID: sendCurrency.id,
            rightCurrencyID: receiveCurrency.id
        )
        logger.info(
            Constants.defaultPairSelectionCompletedMessage,
            metadata: [
                AppLogMetadataKey.baseCurrency: sendCurrency.code,
                AppLogMetadataKey.quoteCurrency: receiveCurrency.code
            ]
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
        logger.warning(
            Constants.exchangeAlertPreparedMessage,
            metadata: [
                AppLogMetadataKey.error: error.logDescription
            ]
        )
        
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
        logger.warning(
            Constants.networkAlertPreparedMessage,
            metadata: [
                AppLogMetadataKey.error: error.logDescription
            ]
        )
        
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
    
    func logCurrencySelectionRejected(_ currency: Currency, side: SelectedSide) {
        logger.warning(
            Constants.currencySelectionRejectedMessage,
            metadata: [
                AppLogMetadataKey.reason: Constants.duplicateCurrencyReason,
                AppLogMetadataKey.side: side.logDescription,
                AppLogMetadataKey.currency: currency.code
            ]
        )
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
        static let currencyLoadingStartedMessage = "P2P currency loading was started."
        static let currencyLoadingCompletedMessage = "P2P currency loading was completed successfully."
        static let currencyLoadingFailedMessage = "P2P currency loading failed."
        static let startSkippedMessage = "P2P exchange start was skipped."
        static let offerRequestRejectedMessage = "P2P offer request was rejected."
        static let currencySelectionCompletedMessage = "P2P currency selection was completed."
        static let currencySelectionRejectedMessage = "P2P currency selection was rejected."
        static let exchangeInputRejectedMessage = "P2P exchange input preparation was rejected."
        static let exchangeRejectedMessage = "P2P exchange was rejected."
        static let exchangeStartedMessage = "P2P exchange was started."
        static let exchangeCompletedMessage = "P2P exchange was completed successfully."
        static let exchangeFailedMessage = "P2P exchange failed."
        static let offerLoadingStartedMessage = "P2P offer loading was started."
        static let offerLoadingCompletedMessage = "P2P offer loading was completed successfully."
        static let offerLoadingFailedMessage = "P2P offer loading failed."
        static let offerLoadingRejectedMessage = "P2P offer loading was rejected."
        static let defaultPairSelectionCompletedMessage = "Default P2P currency pair selection was completed."
        static let defaultPairSelectionRejectedMessage = "Default P2P currency pair selection was rejected."
        static let exchangeAlertPreparedMessage = "P2P exchange error alert was prepared."
        static let networkAlertPreparedMessage = "P2P network error alert was prepared."
        static let alreadyStartedReason = "alreadyStarted"
        static let invalidOfferIndexReason = "invalidOfferIndex"
        static let missingExchangeDataReason = "missingExchangeData"
        static let missingCurrencyPairReason = "missingCurrencyPair"
        static let emptyCurrenciesReason = "emptyCurrencies"
        static let invalidCurrencyPairReason = "invalidCurrencyPair"
        static let duplicateCurrencyReason = "duplicateCurrency"
        static let emptyMetadataValue = "-"
    }
}
