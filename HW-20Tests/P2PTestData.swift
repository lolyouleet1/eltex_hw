import Foundation
@testable import HW_20

enum P2PTestData {
    // MARK: - Currency
    static let sendCurrencyID = UUID(uuidString: Constants.sendCurrencyIDText)!
    static let receiveCurrencyID = UUID(uuidString: Constants.receiveCurrencyIDText)!
    static let alternateCurrencyID = UUID(uuidString: Constants.alternateCurrencyIDText)!
    
    static let sendCurrency = Currency(
        id: sendCurrencyID,
        code: Constants.sendCurrencyCode,
        baseValue: Constants.defaultBaseValue,
        type: .fiat,
        isFavorite: Constants.defaultIsFavorite
    )
    static let receiveCurrency = Currency(
        id: receiveCurrencyID,
        code: Constants.receiveCurrencyCode,
        baseValue: Constants.defaultBaseValue,
        type: .fiat,
        isFavorite: Constants.defaultIsFavorite
    )
    static let alternateCurrency = Currency(
        id: alternateCurrencyID,
        code: Constants.alternateCurrencyCode,
        baseValue: Constants.defaultBaseValue,
        type: .fiat,
        isFavorite: Constants.defaultIsFavorite
    )
    static let currencies = [
        sendCurrency,
        receiveCurrency,
        alternateCurrency
    ]
    static let emptyCurrencies: [Currency] = []
    
    static let apiSendCurrency = APICurrency(
        id: sendCurrencyID,
        code: Constants.sendCurrencyCode,
        name: Constants.sendCurrencyName
    )
    static let apiReceiveCurrency = APICurrency(
        id: receiveCurrencyID,
        code: Constants.receiveCurrencyCode,
        name: Constants.receiveCurrencyName
    )
    static let apiCurrencies = [
        apiSendCurrency,
        apiReceiveCurrency
    ]
    static let emptyAPICurrencies: [APICurrency] = []
    
    // MARK: - Offer
    static let offerID = UUID(uuidString: Constants.offerIDText)!
    static let secondOfferID = UUID(uuidString: Constants.secondOfferIDText)!
    static let offer = P2POffer(
        id: offerID,
        sellerName: Constants.sellerName,
        rate: Constants.offerRate,
        reserve: Constants.offerReserve,
        receiveCurrencyCode: Constants.receiveCurrencyCode
    )
    static let secondOffer = P2POffer(
        id: secondOfferID,
        sellerName: Constants.secondSellerName,
        rate: Constants.secondOfferRate,
        reserve: Constants.secondOfferReserve,
        receiveCurrencyCode: Constants.receiveCurrencyCode
    )
    static let offers = [
        offer,
        secondOffer
    ]
    static let emptyOffers: [P2POffer] = []
    
    static let rateDTO = CurrencyPairRateDTO(
        date: Constants.rateDate,
        base: Constants.sendCurrencyCode,
        quote: Constants.receiveCurrencyCode,
        rate: Constants.offerRate
    )
    static let currencyPairRate = P2PCurrencyPairRate(
        baseCurrencyCode: Constants.sendCurrencyCode,
        receiveCurrencyCode: Constants.receiveCurrencyCode,
        rate: Constants.offerRate
    )
    
    // MARK: - Exchange
    static let exchangeAmountText = Constants.exchangeAmountText
    static let exchangeAmountTextWithComma = Constants.exchangeAmountTextWithComma
    static let highExchangeAmountText = Constants.highExchangeAmountText
    static let invalidExchangeAmountText = Constants.invalidExchangeAmountText
    static let emptyExchangeAmountText = Constants.emptyExchangeAmountText
    static let exchangeSendAmount = Constants.exchangeSendAmount
    static let exchangeReceiveAmount = Constants.exchangeReceiveAmount
    static let initialSendBalance = Constants.initialSendBalance
    static let initialReceiveBalance = Constants.initialReceiveBalance
    static let alternateBalance = Constants.alternateBalance
    static let lowBalance = Constants.lowBalance
    static let exchangeRequest = P2PExchangeRequest(
        offer: offer,
        sendCurrencyCode: Constants.sendCurrencyCode,
        receiveCurrencyCode: Constants.receiveCurrencyCode,
        sendAmount: Constants.exchangeSendAmount,
        receiveAmount: Constants.exchangeReceiveAmount
    )
    static let exchangeResult = P2PExchangeResult(
        sendCurrencyCode: Constants.sendCurrencyCode,
        receiveCurrencyCode: Constants.receiveCurrencyCode,
        sendAmount: Constants.exchangeSendAmount,
        receiveAmount: Constants.exchangeReceiveAmount
    )
    static let balancesByCode = [
        Constants.sendCurrencyCode: Constants.initialSendBalance,
        Constants.receiveCurrencyCode: Constants.initialReceiveBalance,
        Constants.alternateCurrencyCode: Constants.alternateBalance
    ]
    static let emptyCredits: [String: Float] = [:]
    
    // MARK: - View State
    static let defaultCurrencyText = Constants.defaultCurrencyText
    static let defaultEmptyStateText = Constants.defaultEmptyStateText
    static let defaultSendBalanceText = Constants.defaultSendBalanceText
    static let defaultReceiveBalanceText = Constants.defaultReceiveBalanceText
    static let loadingText = Constants.loadingText
    static let noOffersText = Constants.noOffersText
    static let sendBalanceText = makeBalanceText(
        title: Constants.sendBalanceTitle,
        balance: Constants.initialSendBalance,
        currencyCode: Constants.sendCurrencyCode
    )
    static let receiveBalanceText = makeBalanceText(
        title: Constants.receiveBalanceTitle,
        balance: Constants.initialReceiveBalance,
        currencyCode: Constants.receiveCurrencyCode
    )
    static let alternateSendBalanceText = makeBalanceText(
        title: Constants.sendBalanceTitle,
        balance: Constants.alternateBalance,
        currencyCode: Constants.alternateCurrencyCode
    )
    static let offerRateText = makeRateText(for: offer)
    static let offerReserveText = makeReserveText(for: offer)
    static let exchangeInputTitle = "\(Constants.exchangeTitle)\(Constants.textSeparator)\(Constants.sellerName)"
    static let exchangeInputMessage = "\(Constants.rateTitle)\(Constants.sendCurrencyCode)\(Constants.rateSeparator)\(Constants.receiveCurrencyCode)\(Constants.valueSeparator)\(AppConfiguration.PriceFormatting.string(from: Constants.offerRate))"
    static let exchangeInputPlaceholder = "\(Constants.amountPlaceholder)\(Constants.textSeparator)\(Constants.sendCurrencyCode)"
    static let exchangeInputActionTitle = Constants.executeButtonTitle
    static let exchangeInputCancelTitle = Constants.cancelButtonTitle
    
    // MARK: - Alert
    static let noInternetAlertTitle = Constants.noInternetTitle
    static let noInternetAlertMessage = Constants.noInternetMessage
    static let notEnoughMoneyAlertTitle = Constants.notEnoughMoneyTitle
    static let notEnoughMoneyAlertMessage = Constants.notEnoughMoneyMessage
    static let successAlertTitle = Constants.successTitle
    static let successAlertMessage = "\(Constants.sentTitle)\(AppConfiguration.PriceFormatting.string(from: Constants.exchangeSendAmount))\(Constants.textSeparator)\(Constants.sendCurrencyCode)\(Constants.lineSeparator)\(Constants.receivedTitle)\(AppConfiguration.PriceFormatting.string(from: Constants.exchangeReceiveAmount))\(Constants.textSeparator)\(Constants.receiveCurrencyCode)"
    
    // MARK: - Test Values
    static let expectedCallCount = Constants.expectedCallCount
    static let secondCallCount = Constants.secondCallCount
    static let expectedOffersCount = Constants.expectedOffersCount
    static let expectedFactoryOffersCount = Constants.expectedFactoryOffersCount
    static let waitTimeout = Constants.waitTimeout
    static let accuracy = Constants.accuracy
    static let networkError: NetworkError = .noInternet
    static let exchangeError: P2PExchangeError = .notEnoughMoney
}

// MARK: - Private Methods
private extension P2PTestData {
    static func makeBalanceText(title: String, balance: Float, currencyCode: String) -> String {
        "\(title)\(AppConfiguration.PriceFormatting.string(from: balance))\(Constants.textSeparator)\(currencyCode)"
    }
    
    static func makeRateText(for offer: P2POffer) -> String {
        "\(Constants.rateTitle)\(AppConfiguration.PriceFormatting.string(from: offer.rate))\(Constants.textSeparator)\(offer.receiveCurrencyCode)"
    }
    
    static func makeReserveText(for offer: P2POffer) -> String {
        "\(Constants.reserveCellTitle)\(AppConfiguration.PriceFormatting.string(from: offer.reserve))\(Constants.textSeparator)\(offer.receiveCurrencyCode)"
    }
}

// MARK: - Constants
private extension P2PTestData {
    enum Constants {
        static let sendCurrencyIDText = "11111111-1111-1111-1111-111111111111"
        static let receiveCurrencyIDText = "22222222-2222-2222-2222-222222222222"
        static let alternateCurrencyIDText = "33333333-3333-3333-3333-333333333333"
        static let offerIDText = "44444444-4444-4444-4444-444444444444"
        static let secondOfferIDText = "55555555-5555-5555-5555-555555555555"
        static let sendCurrencyCode = "EUR"
        static let receiveCurrencyCode = "USD"
        static let alternateCurrencyCode = "GBP"
        static let sendCurrencyName = "Euro"
        static let receiveCurrencyName = "U.S. Dollar"
        static let defaultBaseValue: Float = 0
        static let defaultIsFavorite = false
        static let sellerName = "Alex Market"
        static let secondSellerName = "Swift Change"
        static let offerRate: Float = 2.5
        static let secondOfferRate: Float = 2.3
        static let offerReserve: Float = 500
        static let secondOfferReserve: Float = 700
        static let rateDate = "2026-05-20"
        static let exchangeAmountText = "100.5"
        static let exchangeAmountTextWithComma = "100,5"
        static let highExchangeAmountText = "1001"
        static let invalidExchangeAmountText = "0"
        static let emptyExchangeAmountText = ""
        static let exchangeSendAmount: Float = 100.5
        static let exchangeReceiveAmount: Float = 251.25
        static let initialSendBalance: Float = 1_000
        static let initialReceiveBalance: Float = 20
        static let alternateBalance: Float = 300
        static let lowBalance: Float = 10
        static let defaultCurrencyText = "Choose"
        static let defaultEmptyStateText = "Choose currency pair"
        static let defaultSendBalanceText = "Send balance: -"
        static let defaultReceiveBalanceText = "Receive balance: -"
        static let sendBalanceTitle = "Send balance: "
        static let receiveBalanceTitle = "Receive balance: "
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
        static let noInternetTitle = "No internet connection"
        static let noInternetMessage = "Check your connection and try again."
        static let notEnoughMoneyTitle = "Not enough balance"
        static let notEnoughMoneyMessage = "There is not enough money in your wallet for this exchange."
        static let successTitle = "Exchange completed"
        static let sentTitle = "Sent: "
        static let receivedTitle = "Received: "
        static let expectedCallCount = 1
        static let secondCallCount = 2
        static let expectedOffersCount = 2
        static let expectedFactoryOffersCount = 8
        static let waitTimeout: TimeInterval = 1
        static let accuracy: Float = 0.001
    }
}
