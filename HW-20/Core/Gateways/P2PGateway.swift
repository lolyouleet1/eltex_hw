import Foundation

protocol P2PGatewayProtocol: AnyObject {
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void)
    func fetchRate(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void)
    func performExchange(request: P2PExchangeRequest, completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void)
}

final class P2PGateway: P2PGatewayProtocol {
    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let logger: AppLoggerProtocol
    
    // MARK: - Lifecycle
    init(networkService: NetworkServiceProtocol, logger: AppLoggerProtocol = AppLogger.p2pTrading) {
        self.networkService = networkService
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void) {
        logger.info(Constants.currencyRequestMessage)
        networkService.fetchCurrencies(completion: completion)
    }
    
    func fetchRate(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void) {
        logger.info(
            Constants.rateRequestMessage,
            metadata: [
                AppLogMetadataKey.baseCurrency: baseCode,
                AppLogMetadataKey.quoteCurrency: quoteCode
            ]
        )
        networkService.fetchRate(
            from: baseCode,
            to: quoteCode,
            completion: completion
        )
    }
    
    func performExchange(request: P2PExchangeRequest, completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void) {
        logger.info(
            Constants.exchangeRequestMessage,
            metadata: [
                AppLogMetadataKey.offerID: request.offer.id.uuidString,
                AppLogMetadataKey.sendCurrency: request.sendCurrencyCode,
                AppLogMetadataKey.receiveCurrency: request.receiveCurrencyCode
            ]
        )
        networkService.performP2PExchange(
            request: request,
            completion: completion
        )
    }
}

// MARK: - Constants
private extension P2PGateway {
    enum Constants {
        static let currencyRequestMessage = "P2P currency gateway request was sent to the network service."
        static let rateRequestMessage = "P2P rate gateway request was sent to the network service."
        static let exchangeRequestMessage = "P2P exchange gateway request was sent to the network service."
    }
}
