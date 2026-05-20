import Foundation
@testable import HW_20

final class P2PRepositoryMock: P2PRepositoryProtocol {
    // MARK: - State
    var getCurrenciesResult: Result<[Currency], NetworkError> = .success(P2PTestData.currencies)
    var getOffersResult: Result<[P2POffer], NetworkError> = .success(P2PTestData.offers)
    var performExchangeResult: Result<P2PExchangeResult, NetworkError> = .success(P2PTestData.exchangeResult)
    
    private(set) var getCurrenciesCallCount = Constants.defaultCallCount
    private(set) var getOffersCallCount = Constants.defaultCallCount
    private(set) var performExchangeCallCount = Constants.defaultCallCount
    private(set) var lastSendCurrencyCode: String?
    private(set) var lastReceiveCurrencyCode: String?
    private(set) var lastOffer: P2POffer?
    private(set) var lastSendAmount: Float?
    private(set) var lastReceiveAmount: Float?
    
    // MARK: - Public Methods
    func getCurrencies(completion: @escaping (Result<[Currency], NetworkError>) -> Void) {
        getCurrenciesCallCount += Constants.callStep
        completion(getCurrenciesResult)
    }
    
    func getOffers(
        sendCurrencyCode: String,
        receiveCurrencyCode: String,
        completion: @escaping (Result<[P2POffer], NetworkError>) -> Void
    ) {
        getOffersCallCount += Constants.callStep
        lastSendCurrencyCode = sendCurrencyCode
        lastReceiveCurrencyCode = receiveCurrencyCode
        completion(getOffersResult)
    }
    
    func performExchange(
        offer: P2POffer,
        sendCurrencyCode: String,
        receiveCurrencyCode: String,
        sendAmount: Float,
        receiveAmount: Float,
        completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void
    ) {
        performExchangeCallCount += Constants.callStep
        lastOffer = offer
        lastSendCurrencyCode = sendCurrencyCode
        lastReceiveCurrencyCode = receiveCurrencyCode
        lastSendAmount = sendAmount
        lastReceiveAmount = receiveAmount
        completion(performExchangeResult)
    }
}

// MARK: - Constants
private extension P2PRepositoryMock {
    enum Constants {
        static let defaultCallCount = 0
        static let callStep = 1
    }
}
