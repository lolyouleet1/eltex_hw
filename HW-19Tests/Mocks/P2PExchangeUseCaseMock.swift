import Foundation
@testable import HW_19

final class P2PExchangeUseCaseMock: P2PExchangeUseCaseProtocol {
    // MARK: - State
    var loadCurrenciesResult: Result<[Currency], NetworkError> = .success(P2PTestData.currencies)
    var loadOffersResult: Result<[P2POffer], NetworkError> = .success(P2PTestData.offers)
    var performExchangeResult: Result<P2PExchangeResult, P2PExchangeError> = .success(P2PTestData.exchangeResult)
    var balancesByCode = P2PTestData.balancesByCode
    
    private(set) var loadCurrenciesCallCount = Constants.defaultCallCount
    private(set) var loadOffersCallCount = Constants.defaultCallCount
    private(set) var performExchangeCallCount = Constants.defaultCallCount
    private(set) var balanceCallCount = Constants.defaultCallCount
    private(set) var lastSendCurrency: Currency?
    private(set) var lastReceiveCurrency: Currency?
    private(set) var lastOffer: P2POffer?
    private(set) var lastAmountText: String?
    private(set) var lastBalanceCurrencyCode: String?
    
    // MARK: - Public Methods
    func loadCurrencies(completion: @escaping (Result<[Currency], NetworkError>) -> Void) {
        loadCurrenciesCallCount += Constants.callStep
        completion(loadCurrenciesResult)
    }
    
    func loadOffers(
        sendCurrency: Currency,
        receiveCurrency: Currency,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        loadOffersCallCount += Constants.callStep
        lastSendCurrency = sendCurrency
        lastReceiveCurrency = receiveCurrency
        completion(loadOffersResult)
    }
    
    func performExchange(
        offer: P2POffer,
        sendCurrency: Currency,
        receiveCurrency: Currency,
        amountText: String?,
        completion: @escaping (Result<P2PExchangeResult, P2PExchangeError>) -> Void
    ) {
        performExchangeCallCount += Constants.callStep
        lastOffer = offer
        lastSendCurrency = sendCurrency
        lastReceiveCurrency = receiveCurrency
        lastAmountText = amountText
        completion(performExchangeResult)
    }
    
    func balance(for currencyCode: String) -> Float {
        balanceCallCount += Constants.callStep
        lastBalanceCurrencyCode = currencyCode
        
        return balancesByCode[currencyCode, default: Constants.defaultBalance]
    }
}

// MARK: - Constants
private extension P2PExchangeUseCaseMock {
    enum Constants {
        static let defaultCallCount = 0
        static let callStep = 1
        static let defaultBalance: Float = 0
    }
}
