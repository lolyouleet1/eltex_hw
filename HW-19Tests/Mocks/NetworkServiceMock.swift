import Combine
import Foundation
@testable import HW_19

final class NetworkServiceMock: NetworkServiceProtocol {
    // MARK: - State
    var isNetworkWithCombine = Constants.defaultIsNetworkWithCombine
    var fetchCurrenciesResult: Result<[APICurrency], NetworkError> = .success(P2PTestData.apiCurrencies)
    var fetchRateResult: Result<CurrencyPairRateDTO, NetworkError> = .success(P2PTestData.rateDTO)
    var performExchangeResult: Result<P2PExchangeResult, NetworkError> = .success(P2PTestData.exchangeResult)
    
    private(set) var fetchCurrenciesCallCount = Constants.defaultCallCount
    private(set) var fetchCurrenciesPublisherCallCount = Constants.defaultCallCount
    private(set) var fetchRateCallCount = Constants.defaultCallCount
    private(set) var fetchRatePublisherCallCount = Constants.defaultCallCount
    private(set) var performExchangeCallCount = Constants.defaultCallCount
    private(set) var performExchangePublisherCallCount = Constants.defaultCallCount
    private(set) var lastBaseCode: String?
    private(set) var lastQuoteCode: String?
    private(set) var lastRequest: P2PExchangeRequest?
    
    // MARK: - Public Methods
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void) {
        fetchCurrenciesCallCount += Constants.callStep
        completion(fetchCurrenciesResult)
    }
    
    func fetchCurrenciesPublisher() -> AnyPublisher<[APICurrency], NetworkError> {
        fetchCurrenciesPublisherCallCount += Constants.callStep
        
        return makePublisher(from: fetchCurrenciesResult)
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
    
    func fetchRatePublisher(from baseCode: String, to quoteCode: String) -> AnyPublisher<CurrencyPairRateDTO, NetworkError> {
        fetchRatePublisherCallCount += Constants.callStep
        lastBaseCode = baseCode
        lastQuoteCode = quoteCode
        
        return makePublisher(from: fetchRateResult)
    }
    
    func performP2PExchange(
        request: P2PExchangeRequest,
        completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void
    ) {
        performExchangeCallCount += Constants.callStep
        lastRequest = request
        completion(performExchangeResult)
    }
    
    func performP2PExchangePublisher(request: P2PExchangeRequest) -> AnyPublisher<P2PExchangeResult, NetworkError> {
        performExchangePublisherCallCount += Constants.callStep
        lastRequest = request
        
        return makePublisher(from: performExchangeResult)
    }
}

// MARK: - Private Methods
private extension NetworkServiceMock {
    func makePublisher<Value>(from result: Result<Value, NetworkError>) -> AnyPublisher<Value, NetworkError> {
        switch result {
        case .success(let value):
            return Just(value)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - Constants
private extension NetworkServiceMock {
    enum Constants {
        static let defaultIsNetworkWithCombine = false
        static let defaultCallCount = 0
        static let callStep = 1
    }
}
