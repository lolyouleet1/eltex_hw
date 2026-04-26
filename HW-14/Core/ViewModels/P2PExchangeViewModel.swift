import Foundation

final class P2PExchangeViewModel {
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
    
    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let wallet: Wallet
    private let offerFactory: P2POfferFactory
    private let currencySelectionService: CurrencySelectionService
    
    // MARK: - State
    private var apiCurrencies: [Currency] = []
    private var selectedSendCurrency: Currency?
    private var selectedReceiveCurrency: Currency?
    private var offers: [P2POffer] = []
    private var isLoading = false
    private var didStart = false
    
    private(set) var viewState: ViewState
    var onStateChange: ((ViewState) -> Void)?
    var onAlert: ((P2PAlertViewModel) -> Void)?
    
    // MARK: - Lifecycle
    init(
        networkService: NetworkServiceProtocol,
        wallet: Wallet,
        offerFactory: P2POfferFactory,
        currencySelectionService: CurrencySelectionService
    ) {
        self.networkService = networkService
        self.wallet = wallet
        self.offerFactory = offerFactory
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
        isLoading = true
        publishState()
        
        networkService.fetchCurrencies { [weak self] result in
            DispatchQueue.main.async {
                self?.handleCurrenciesResult(result)
            }
        }
    }
    
    func availableCurrencies() -> [Currency] {
        apiCurrencies
    }
    
    func handleCurrencySelection(_ currency: Currency, for side: SelectedSide) {
        switch side {
        case .left:
            guard selectedReceiveCurrency?.id != currency.id else { return }
            selectedSendCurrency = currency
        case .right:
            guard selectedSendCurrency?.id != currency.id else { return }
            selectedReceiveCurrency = currency
        }
        
        _ = currencySelectionService.select(currencyID: currency.id, for: side)
        loadOffers()
    }
    
    func exchangeInputViewModel(for index: Int) -> P2PExchangeInputViewModel? {
        guard offers.indices.contains(index),
              let sendCurrency = selectedSendCurrency,
              let receiveCurrency = selectedReceiveCurrency else {
            return nil
        }
        
        let offer = offers[index]
        let rateText = AppConfiguration.PriceFormatting.string(from: offer.rate)
        
        return P2PExchangeInputViewModel(
            title: "\(Constants.exchangeTitle) \(offer.sellerName)",
            message: "\(Constants.rateTitle)\(sendCurrency.code)\(Constants.rateSeparator)\(receiveCurrency.code): \(rateText)",
            placeholder: "\(Constants.amountPlaceholder) \(sendCurrency.code)",
            actionTitle: Constants.executeButtonTitle,
            cancelTitle: Constants.cancelButtonTitle
        )
    }
    
    func performExchange(offerIndex: Int, amountText: String?) {
        guard offers.indices.contains(offerIndex),
              let sendCurrency = selectedSendCurrency,
              let receiveCurrency = selectedReceiveCurrency else {
            showAlert(for: .operationFailed)
            return
        }
        
        let offer = offers[offerIndex]
        guard let sendAmount = makeAmount(from: amountText), sendAmount > .zero else {
            showValidationAlert(title: Constants.invalidAmountTitle, message: Constants.invalidAmountMessage)
            return
        }
        
        guard wallet.balance(for: sendCurrency.code) >= sendAmount else {
            showValidationAlert(title: Constants.notEnoughMoneyTitle, message: Constants.notEnoughMoneyMessage)
            return
        }
        
        let receiveAmount = AppConfiguration.PriceFormatting.rounded(sendAmount * offer.rate)
        guard receiveAmount <= offer.reserve else {
            showValidationAlert(title: Constants.reserveTitle, message: Constants.reserveMessage)
            return
        }
        
        let request = P2PExchangeRequest(
            offer: offer,
            sendCurrencyCode: sendCurrency.code,
            receiveCurrencyCode: receiveCurrency.code,
            sendAmount: sendAmount,
            receiveAmount: receiveAmount
        )
        
        isLoading = true
        publishState()
        
        networkService.performP2PExchange(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleExchangeResult(result)
            }
        }
    }
}

// MARK: - Private Methods
private extension P2PExchangeViewModel {
    func handleCurrenciesResult(_ result: Result<[APICurrency], NetworkError>) {
        isLoading = false
        
        switch result {
        case .success(let currencies):
            apiCurrencies = currencies.map {
                Currency(
                    id: $0.id,
                    code: $0.code,
                    baseValue: .zero,
                    type: .fiat,
                    isFavorite: false
                )
            }
            selectDefaultPair()
            loadOffers()
        case .failure(let error):
            offers.removeAll()
            rebuildState()
            onStateChange?(viewState)
            showAlert(for: error)
        }
    }
    
    func handleExchangeResult(_ result: Result<P2PExchangeResult, NetworkError>) {
        isLoading = false
        
        switch result {
        case .success(let result):
            let isCompleted = wallet.exchange(
                sendCurrencyCode: result.sendCurrencyCode,
                receiveCurrencyCode: result.receiveCurrencyCode,
                sendAmount: result.sendAmount,
                receiveAmount: result.receiveAmount
            )
            
            if isCompleted {
                publishState()
                showSuccessAlert(result)
            } else {
                publishState()
                showValidationAlert(title: Constants.notEnoughMoneyTitle, message: Constants.notEnoughMoneyMessage)
            }
        case .failure(let error):
            publishState()
            showAlert(for: error)
        }
    }
    
    func loadOffers() {
        guard let sendCurrency = selectedSendCurrency,
              let receiveCurrency = selectedReceiveCurrency else {
            offers.removeAll()
            publishState()
            return
        }
        
        isLoading = true
        offers.removeAll()
        publishState()
        
        networkService.fetchRate(from: sendCurrency.code, to: receiveCurrency.code) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleRateResult(result)
            }
        }
    }
    
    func handleRateResult(_ result: Result<CurrencyPairRateDTO, NetworkError>) {
        isLoading = false
        
        switch result {
        case .success(let rate):
            offers = offerFactory.makeOffers(
                rate: rate.rate,
                receiveCurrencyCode: rate.quote
            )
            publishState()
        case .failure(let error):
            offers.removeAll()
            publishState()
            showAlert(for: error)
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
    
    var emptyStateText: String {
        if isLoading {
            return Constants.loadingText
        }
        
        if selectedSendCurrency == nil || selectedReceiveCurrency == nil {
            return Constants.defaultEmptyStateText
        }
        
        return Constants.noOffersText
    }
    
    func makeRateText(for offer: P2POffer) -> String {
        let rate = AppConfiguration.PriceFormatting.string(from: offer.rate)
        
        return "\(Constants.rateTitle)\(rate) \(offer.receiveCurrencyCode)"
    }
    
    func makeReserveText(for offer: P2POffer) -> String {
        let reserve = AppConfiguration.PriceFormatting.string(from: offer.reserve)
        
        return "\(Constants.reserveCellTitle)\(reserve) \(offer.receiveCurrencyCode)"
    }
    
    func makeBalanceText(for currency: Currency?, title: String) -> String {
        guard let currency else {
            return title + Constants.emptyBalanceText
        }
        
        let balance = AppConfiguration.PriceFormatting.string(
            from: wallet.balance(for: currency.code)
        )
        
        return "\(title)\(balance) \(currency.code)"
    }
    
    func makeAmount(from text: String?) -> Float? {
        let text = text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: Constants.commaSeparator, with: Constants.dotSeparator)
        
        guard let text, !text.isEmpty else { return nil }
        
        return Float(text)
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
        let message = "\(Constants.sentTitle)\(sendAmount) \(result.sendCurrencyCode)\n\(Constants.receivedTitle)\(receiveAmount) \(result.receiveCurrencyCode)"
        
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
        static let serviceUnavailableMessage = "FloatRates API is not responding. Try again later or check the simulator network."
        static let parsingTitle = "Something went wrong"
        static let parsingMessage = "Please try again later."
        static let accessDeniedTitle = "Access denied"
        static let accessDeniedMessage = "You do not have permission to view this section."
        static let operationFailedTitle = "Operation failed"
        static let operationFailedMessage = "The exchange was not completed. Please try again."
        static let successTitle = "Exchange completed"
        static let sentTitle = "Sent: "
        static let receivedTitle = "Received: "
        static let commaSeparator = ","
        static let dotSeparator = "."
    }
}
