import Foundation

protocol P2PGatewayProtocol: AnyObject {
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void)
    func fetchRate(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void)
    func performExchange(request: P2PExchangeRequest, completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void)
}

final class P2PGateway: P2PGatewayProtocol {
    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Lifecycle
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - Public Methods
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void) {
        networkService.fetchCurrencies(completion: completion)
    }
    
    func fetchRate(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void) {
        networkService.fetchRate(
            from: baseCode,
            to: quoteCode,
            completion: completion
        )
    }
    
    func performExchange(request: P2PExchangeRequest, completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void) {
        networkService.performP2PExchange(
            request: request,
            completion: completion
        )
    }
}
