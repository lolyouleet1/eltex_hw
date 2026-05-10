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
    
    // MARK: - Lifecycle
    init(
        gateway: P2PGatewayProtocol,
        dataMapper: P2PDataMapperProtocol,
        offerFactory: P2POfferFactory
    ) {
        self.gateway = gateway
        self.dataMapper = dataMapper
        self.offerFactory = offerFactory
    }
    
    // MARK: - Public Methods
    func getCurrencies(completion: @escaping (Result<[Currency], NetworkError>) -> Void) {
        gateway.fetchCurrencies { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let currencies):
                completion(.success(dataMapper.makeCurrencies(from: currencies)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getOffers(sendCurrencyCode: String, receiveCurrencyCode: String, completion: @escaping (Result<[P2POffer], NetworkError>) -> Void) {
        gateway.fetchRate(from: sendCurrencyCode, to: receiveCurrencyCode) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let rateDTO):
                let rate = dataMapper.makeRate(from: rateDTO)
                let offers = offerFactory.makeOffers(
                    rate: rate.rate,
                    receiveCurrencyCode: rate.receiveCurrencyCode
                )
                
                completion(.success(offers))
            case .failure(let error):
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
        
        gateway.performExchange(
            request: request,
            completion: completion
        )
    }
}
