import Foundation

protocol P2PRepositoryProtocol: AnyObject {
    func getCurrencies(completion: @escaping (Result<[Currency], NetworkError>) -> Void)
    func getOffers(sendCurrencyCode: String, receiveCurrencyCode: String, completion: @escaping (Result<[P2POffer], NetworkError>) -> Void)
    func performExchange(
        offer: P2POffer,
        sendCurrencyCode: String,
        receiveCurrencyCode: String,
        sendAmount: Float,
        receiveAmount: Float,
        completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void
    )
}

final class P2PRepository: P2PRepositoryProtocol {
    // MARK: - Dependencies
    private let gateway: P2PGatewayProtocol
    private let dataMapper: P2PDataMapperProtocol
    private let offerFactory: P2POfferFactory
    private let logger: AppLoggerProtocol
    
    // MARK: - Lifecycle
    init(
        gateway: P2PGatewayProtocol,
        dataMapper: P2PDataMapperProtocol,
        offerFactory: P2POfferFactory,
        logger: AppLoggerProtocol = AppLogger.p2pTrading
    ) {
        self.gateway = gateway
        self.dataMapper = dataMapper
        self.offerFactory = offerFactory
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func getCurrencies(completion: @escaping (Result<[Currency], NetworkError>) -> Void) {
        logger.info(Constants.currencyRequestStartedMessage)
        gateway.fetchCurrencies { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let currencies):
                let mappedCurrencies = dataMapper.makeCurrencies(from: currencies)
                logger.info(
                    Constants.currencyRequestCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.count: String(mappedCurrencies.count)
                    ]
                )
                completion(.success(mappedCurrencies))
            case .failure(let error):
                logger.error(
                    Constants.currencyRequestFailedMessage,
                    metadata: [
                        AppLogMetadataKey.error: error.logDescription
                    ]
                )
                completion(.failure(error))
            }
        }
    }
    
    func getOffers(sendCurrencyCode: String, receiveCurrencyCode: String, completion: @escaping (Result<[P2POffer], NetworkError>) -> Void) {
        logger.info(
            Constants.offerRequestStartedMessage,
            metadata: [
                AppLogMetadataKey.baseCurrency: sendCurrencyCode,
                AppLogMetadataKey.quoteCurrency: receiveCurrencyCode
            ]
        )
        gateway.fetchRate(from: sendCurrencyCode, to: receiveCurrencyCode) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let rateDTO):
                let rate = dataMapper.makeRate(from: rateDTO)
                let offers = offerFactory.makeOffers(
                    rate: rate.rate,
                    receiveCurrencyCode: rate.receiveCurrencyCode
                )
                
                logger.info(
                    Constants.offerRequestCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.count: String(offers.count),
                        AppLogMetadataKey.receiveCurrency: rate.receiveCurrencyCode
                    ]
                )
                completion(.success(offers))
            case .failure(let error):
                logger.error(
                    Constants.offerRequestFailedMessage,
                    metadata: [
                        AppLogMetadataKey.error: error.logDescription
                    ]
                )
                completion(.failure(error))
            }
        }
    }
    
    func performExchange(
        offer: P2POffer,
        sendCurrencyCode: String,
        receiveCurrencyCode: String,
        sendAmount: Float,
        receiveAmount: Float,
        completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void
    ) {
        let request = dataMapper.makeExchangeRequest(
            offer: offer,
            sendCurrencyCode: sendCurrencyCode,
            receiveCurrencyCode: receiveCurrencyCode,
            sendAmount: sendAmount,
            receiveAmount: receiveAmount
        )
        
        logger.info(
            Constants.exchangeRequestStartedMessage,
            metadata: [
                AppLogMetadataKey.offerID: offer.id.uuidString,
                AppLogMetadataKey.sendCurrency: sendCurrencyCode,
                AppLogMetadataKey.receiveCurrency: receiveCurrencyCode
            ]
        )
        gateway.performExchange(
            request: request,
            completion: { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success:
                    logger.info(Constants.exchangeRequestCompletedMessage)
                case .failure(let error):
                    logger.error(
                        Constants.exchangeRequestFailedMessage,
                        metadata: [
                            AppLogMetadataKey.error: error.logDescription
                        ]
                    )
                }
                
                completion(result)
            }
        )
    }
}

// MARK: - Constants
private extension P2PRepository {
    enum Constants {
        static let currencyRequestStartedMessage = "P2P currency repository request was started."
        static let currencyRequestCompletedMessage = "P2P currency repository request was completed successfully."
        static let currencyRequestFailedMessage = "P2P currency repository request failed."
        static let offerRequestStartedMessage = "P2P offer repository request was started."
        static let offerRequestCompletedMessage = "P2P offer repository request was completed successfully."
        static let offerRequestFailedMessage = "P2P offer repository request failed."
        static let exchangeRequestStartedMessage = "P2P exchange repository request was started."
        static let exchangeRequestCompletedMessage = "P2P exchange repository request was completed successfully."
        static let exchangeRequestFailedMessage = "P2P exchange repository request failed."
    }
}
