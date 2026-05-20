import Foundation
@testable import HW_19

final class P2PGatewayMock: P2PGatewayProtocol {
    // MARK: - State
    var fetchCurrenciesResult: Result<[APICurrency], NetworkError> = .success(P2PTestData.apiCurrencies)
    var fetchRateResult: Result<CurrencyPairRateDTO, NetworkError> = .success(P2PTestData.rateDTO)
    var performExchangeResult: Result<P2PExchangeResult, NetworkError> = .success(P2PTestData.exchangeResult)
    
    private(set) var fetchCurrenciesCallCount = Constants.defaultCallCount
    private(set) var fetchRateCallCount = Constants.defaultCallCount
    private(set) var performExchangeCallCount = Constants.defaultCallCount
    private(set) var lastBaseCode: String?
    private(set) var lastQuoteCode: String?
    private(set) var lastRequest: P2PExchangeRequest?
    
    // MARK: - Public Methods
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void) {
        fetchCurrenciesCallCount += Constants.callStep
        completion(fetchCurrenciesResult)
    }
    
    func fetchRate(
        from baseCode: String,
        to quoteCode: String,
        completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void
    ) {
        fetchRateCallCount += Constants.callStep
        lastBaseCode = baseCode
        lastQuoteCode = quoteCode
        completion(fetchRateResult)
    }
    
    func performExchange(
        request: P2PExchangeRequest,
        completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void
    ) {
        performExchangeCallCount += Constants.callStep
        lastRequest = request
        completion(performExchangeResult)
    }
}

// MARK: - Constants
private extension P2PGatewayMock {
    enum Constants {
        static let defaultCallCount = 0
        static let callStep = 1
    }
}
