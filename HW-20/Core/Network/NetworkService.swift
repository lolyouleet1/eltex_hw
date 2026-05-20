import Combine
import Foundation

protocol NetworkServiceProtocol: AnyObject {
    var isNetworkWithCombine: Bool { get set }
    
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void)
    func fetchCurrenciesPublisher() -> AnyPublisher<[APICurrency], NetworkError>
    func fetchRate(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void)
    func fetchRatePublisher(from baseCode: String, to quoteCode: String) -> AnyPublisher<CurrencyPairRateDTO, NetworkError>
    func performP2PExchange(request: P2PExchangeRequest, completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void)
    func performP2PExchangePublisher(request: P2PExchangeRequest) -> AnyPublisher<P2PExchangeResult, NetworkError>
}

final class NetworkService: NetworkServiceProtocol {
    // MARK: - Dependencies
    private let session: URLSession
    private let decoder: JSONDecoder
    private let logger: AppLoggerProtocol
    
    // MARK: - State
    var isNetworkWithCombine: Bool
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        isNetworkWithCombine: Bool = AppConfiguration.Network.isNetworkWithCombine,
        logger: AppLoggerProtocol = AppLogger.network
    ) {
        self.session = session
        self.decoder = decoder
        self.isNetworkWithCombine = isNetworkWithCombine
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void) {
        logger.info(
            Constants.currenciesRequestStartedMessage,
            metadata: [
                AppLogMetadataKey.strategy: networkStrategyText
            ]
        )
        
        guard isNetworkWithCombine else {
            fetchCurrenciesWithCompletion(completion: completion)
            return
        }
        
        handlePublisherOutput(
            from: fetchCurrenciesPublisher(),
            completion: completion
        )
    }
    
    func fetchCurrenciesPublisher() -> AnyPublisher<[APICurrency], NetworkError> {
        guard let url = makeDailyRatesURL(for: Constants.currenciesBaseCurrencyCode) else {
            logger.error(
                Constants.invalidURLMessage,
                metadata: [
                    AppLogMetadataKey.request: Constants.currenciesRequestName
                ]
            )
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return performRequestPublisher(url: url)
            .tryMap { [weak self] (response: [String: FloatRatesRateDTO]) -> [APICurrency] in
                guard let self else {
                    throw NetworkError.operationFailed
                }
                
                let currencies = makeCurrencies(from: response)
                guard !currencies.isEmpty else {
                    logger.error(Constants.emptyCurrenciesResponseMessage)
                    throw NetworkError.parsingFailed
                }
                
                logger.info(
                    Constants.currenciesRequestCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.count: String(currencies.count)
                    ]
                )
                return currencies
            }
            .mapError { error in
                error as? NetworkError ?? .operationFailed
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRate(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void) {
        logger.info(
            Constants.rateRequestStartedMessage,
            metadata: [
                AppLogMetadataKey.baseCurrency: baseCode,
                AppLogMetadataKey.quoteCurrency: quoteCode,
                AppLogMetadataKey.strategy: networkStrategyText
            ]
        )
        
        guard isNetworkWithCombine else {
            fetchRateWithCompletion(
                from: baseCode,
                to: quoteCode,
                completion: completion
            )
            return
        }
        
        handlePublisherOutput(
            from: fetchRatePublisher(from: baseCode, to: quoteCode),
            completion: completion
        )
    }
    
    func fetchRatePublisher(from baseCode: String, to quoteCode: String) -> AnyPublisher<CurrencyPairRateDTO, NetworkError> {
        guard let url = makeDailyRatesURL(for: baseCode) else {
            logger.error(
                Constants.invalidURLMessage,
                metadata: [
                    AppLogMetadataKey.baseCurrency: baseCode,
                    AppLogMetadataKey.quoteCurrency: quoteCode,
                    AppLogMetadataKey.request: Constants.rateRequestName
                ]
            )
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return performRequestPublisher(url: url)
            .tryMap { [weak self] (response: [String: FloatRatesRateDTO]) -> CurrencyPairRateDTO in
                guard let self else {
                    throw NetworkError.operationFailed
                }
                
                guard let rate = makeCurrencyPairRate(
                    from: response,
                    baseCode: baseCode,
                    quoteCode: quoteCode
                ) else {
                    logger.error(
                        Constants.rateParsingFailedMessage,
                        metadata: [
                            AppLogMetadataKey.baseCurrency: baseCode,
                            AppLogMetadataKey.quoteCurrency: quoteCode
                        ]
                    )
                    throw NetworkError.parsingFailed
                }
                
                logger.info(
                    Constants.rateRequestCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.baseCurrency: rate.base,
                        AppLogMetadataKey.quoteCurrency: rate.quote
                    ]
                )
                return rate
            }
            .mapError { error in
                error as? NetworkError ?? .operationFailed
            }
            .eraseToAnyPublisher()
    }
    
    func performP2PExchange(request: P2PExchangeRequest, completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void) {
        logger.info(
            Constants.exchangeRequestStartedMessage,
            metadata: [
                AppLogMetadataKey.offerID: request.offer.id.uuidString,
                AppLogMetadataKey.strategy: networkStrategyText
            ]
        )
        
        guard isNetworkWithCombine else {
            performP2PExchangeWithCompletion(request: request, completion: completion)
            return
        }
        
        handlePublisherOutput(
            from: performP2PExchangePublisher(request: request),
            completion: completion
        )
    }
    
    func performP2PExchangePublisher(request: P2PExchangeRequest) -> AnyPublisher<P2PExchangeResult, NetworkError> {
        if Bool.random() {
            let result = P2PExchangeResult(
                sendCurrencyCode: request.sendCurrencyCode,
                receiveCurrencyCode: request.receiveCurrencyCode,
                sendAmount: request.sendAmount,
                receiveAmount: request.receiveAmount
            )
            
            logger.info(Constants.exchangeRequestCompletedMessage)
            return Just(result)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        guard let url = makeFailedExchangeURL() else {
            logger.error(
                Constants.invalidURLMessage,
                metadata: [
                    AppLogMetadataKey.request: Constants.exchangeRequestName
                ]
            )
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return performRequestPublisher(url: url)
            .flatMap { [weak self] (_: [String: FloatRatesRateDTO]) -> AnyPublisher<P2PExchangeResult, NetworkError> in
                self?.logger.error(
                    Constants.exchangeRequestFailedMessage,
                    metadata: [
                        AppLogMetadataKey.error: NetworkError.operationFailed.logDescription
                    ]
                )
                return Fail<P2PExchangeResult, NetworkError>(error: .operationFailed).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Methods
private extension NetworkService {
    func fetchCurrenciesWithCompletion(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void) {
        guard let url = makeDailyRatesURL(for: Constants.currenciesBaseCurrencyCode) else {
            logger.error(
                Constants.invalidURLMessage,
                metadata: [
                    AppLogMetadataKey.request: Constants.currenciesRequestName
                ]
            )
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url) { [weak self] (result: Result<[String: FloatRatesRateDTO], NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                let currencies = makeCurrencies(from: response)
                guard !currencies.isEmpty else {
                    logger.error(Constants.emptyCurrenciesResponseMessage)
                    completion(.failure(.parsingFailed))
                    return
                }
                
                logger.info(
                    Constants.currenciesRequestCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.count: String(currencies.count)
                    ]
                )
                completion(.success(currencies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRateWithCompletion(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void) {
        guard let url = makeDailyRatesURL(for: baseCode) else {
            logger.error(
                Constants.invalidURLMessage,
                metadata: [
                    AppLogMetadataKey.baseCurrency: baseCode,
                    AppLogMetadataKey.quoteCurrency: quoteCode,
                    AppLogMetadataKey.request: Constants.rateRequestName
                ]
            )
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url) { [weak self] (result: Result<[String: FloatRatesRateDTO], NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                guard let rate = makeCurrencyPairRate(
                    from: response,
                    baseCode: baseCode,
                    quoteCode: quoteCode
                ) else {
                    logger.error(
                        Constants.rateParsingFailedMessage,
                        metadata: [
                            AppLogMetadataKey.baseCurrency: baseCode,
                            AppLogMetadataKey.quoteCurrency: quoteCode
                        ]
                    )
                    completion(.failure(.parsingFailed))
                    return
                }
                
                logger.info(
                    Constants.rateRequestCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.baseCurrency: rate.base,
                        AppLogMetadataKey.quoteCurrency: rate.quote
                    ]
                )
                completion(.success(rate))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func performP2PExchangeWithCompletion(request: P2PExchangeRequest, completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void) {
        if Bool.random() {
            let result = P2PExchangeResult(
                sendCurrencyCode: request.sendCurrencyCode,
                receiveCurrencyCode: request.receiveCurrencyCode,
                sendAmount: request.sendAmount,
                receiveAmount: request.receiveAmount
            )
            
            logger.info(Constants.exchangeRequestCompletedMessage)
            completion(.success(result))
            return
        }
        
        guard let url = makeFailedExchangeURL() else {
            logger.error(
                Constants.invalidURLMessage,
                metadata: [
                    AppLogMetadataKey.request: Constants.exchangeRequestName
                ]
            )
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url) { (result: Result<[String: FloatRatesRateDTO], NetworkError>) in
            switch result {
            case .success:
                self.logger.error(
                    Constants.exchangeRequestFailedMessage,
                    metadata: [
                        AppLogMetadataKey.error: NetworkError.operationFailed.logDescription
                    ]
                )
                completion(.failure(.operationFailed))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func handlePublisherOutput<Value>(
        from publisher: AnyPublisher<Value, NetworkError>,
        completion: @escaping (Result<Value, NetworkError>) -> Void
    ) {
        publisher
            .sink { result in
                if case .failure(let error) = result {
                    self.logger.error(
                        Constants.publisherRequestFailedMessage,
                        metadata: [
                            AppLogMetadataKey.error: error.logDescription
                        ]
                    )
                    completion(.failure(error))
                }
            } receiveValue: { value in
                completion(.success(value))
            }
            .store(in: &cancellables)
    }
    
    func makeDailyRatesURL(for currencyCode: String) -> URL? {
        let apiCurrencyCode = makeAPICurrencyCode(from: currencyCode)
        let urlText = "\(Constants.apiBaseURL)\(Constants.dailyRatesPath)\(Constants.pathSeparator)\(apiCurrencyCode)\(Constants.jsonSuffix)"
        
        return URL(string: urlText)
    }
    
    func makeFailedExchangeURL() -> URL? {
        let urlText = "\(Constants.apiBaseURL)\(Constants.dailyRatesPath)\(Constants.pathSeparator)\(Constants.failedExchangeFileName)\(Constants.jsonSuffix)"
        
        return URL(string: urlText)
    }
    
    func makeAPICurrencyCode(from currencyCode: String) -> String {
        currencyCode.lowercased(with: Constants.apiLocale)
    }
    
    func makeAppCurrencyCode(from currencyCode: String) -> String {
        currencyCode.uppercased(with: Constants.apiLocale)
    }
    
    var networkStrategyText: String {
        isNetworkWithCombine ? Constants.combineStrategy : Constants.completionStrategy
    }
    
    func makeCurrencies(from response: [String: FloatRatesRateDTO]) -> [APICurrency] {
        var currenciesByCode: [String: APICurrency] = [
            Constants.currenciesBaseCurrencyCode: APICurrency(
                id: UUID(),
                code: Constants.currenciesBaseCurrencyCode,
                name: Constants.currenciesBaseCurrencyName
            )
        ]
        
        for item in response.values {
            guard let currency = makeCurrency(from: item) else { continue }
            
            currenciesByCode[currency.code] = currency
        }
        
        return currenciesByCode.values.sorted { $0.code < $1.code }
    }
    
    func makeCurrency(from item: FloatRatesRateDTO) -> APICurrency? {
        let code = makeAppCurrencyCode(from: item.code.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !code.isEmpty else { return nil }
        
        let name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return APICurrency(
            id: UUID(),
            code: code,
            name: name.isEmpty ? code : name
        )
    }
    
    func makeCurrencyPairRate(
        from response: [String: FloatRatesRateDTO],
        baseCode: String,
        quoteCode: String
    ) -> CurrencyPairRateDTO? {
        let quoteAPIKey = makeAPICurrencyCode(from: quoteCode)
        guard let rateItem = response[quoteAPIKey],
              rateItem.rate > Constants.minimumRate else {
            return nil
        }
        
        return CurrencyPairRateDTO(
            date: rateItem.date,
            base: makeAppCurrencyCode(from: baseCode),
            quote: makeAppCurrencyCode(from: rateItem.code),
            rate: rateItem.rate
        )
    }
    
    func makeRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = Constants.getMethod
        request.timeoutInterval = Constants.requestTimeout
        
        return request
    }
    
    func performRequest<Response: Decodable>(
        url: URL,
        completion: @escaping (Result<Response, NetworkError>) -> Void
    ) {
        let request = makeRequest(url: url)
        
        logger.info(
            Constants.httpRequestStartedMessage,
            metadata: [
                AppLogMetadataKey.url: url.absoluteString
            ]
        )
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error = error {
                let networkError = makeNetworkError(from: error)
                logger.error(
                    Constants.httpRequestFailedMessage,
                    metadata: [
                        AppLogMetadataKey.error: networkError.logDescription,
                        AppLogMetadataKey.url: url.absoluteString
                    ]
                )
                completion(.failure(networkError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error(
                    Constants.invalidResponseMessage,
                    metadata: [
                        AppLogMetadataKey.url: url.absoluteString
                    ]
                )
                completion(.failure(.invalidResponse))
                return
            }
            
            guard Constants.successStatusCodes.contains(httpResponse.statusCode) else {
                logger.error(
                    Constants.httpStatusCodeRejectedMessage,
                    metadata: [
                        AppLogMetadataKey.statusCode: String(httpResponse.statusCode),
                        AppLogMetadataKey.url: url.absoluteString
                    ]
                )
                completion(.failure(makeNetworkError(from: httpResponse.statusCode)))
                return
            }
            
            guard let data else {
                logger.error(
                    Constants.invalidResponseMessage,
                    metadata: [
                        AppLogMetadataKey.url: url.absoluteString
                    ]
                )
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let response = try decoder.decode(Response.self, from: data)
                logger.info(
                    Constants.httpRequestCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.statusCode: String(httpResponse.statusCode),
                        AppLogMetadataKey.url: url.absoluteString
                    ]
                )
                completion(.success(response))
            } catch {
                logger.error(
                    Constants.decodingFailedMessage,
                    metadata: [
                        AppLogMetadataKey.url: url.absoluteString
                    ]
                )
                completion(.failure(.parsingFailed))
            }
        }.resume()
    }
    
    func performRequestPublisher<Response: Decodable>(url: URL) -> AnyPublisher<Response, NetworkError> {
        let request = makeRequest(url: url)
        
        logger.info(
            Constants.httpRequestStartedMessage,
            metadata: [
                AppLogMetadataKey.url: url.absoluteString
            ]
        )
        return session.dataTaskPublisher(for: request)
            .mapError { [weak self] error in
                let networkError = self?.makeNetworkError(from: error) ?? .operationFailed
                self?.logger.error(
                    Constants.httpRequestFailedMessage,
                    metadata: [
                        AppLogMetadataKey.error: networkError.logDescription,
                        AppLogMetadataKey.url: url.absoluteString
                    ]
                )
                
                return networkError
            }
            .tryMap { [weak self] data, response -> Data in
                guard let self else {
                    throw NetworkError.operationFailed
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    logger.error(
                        Constants.invalidResponseMessage,
                        metadata: [
                            AppLogMetadataKey.url: url.absoluteString
                        ]
                    )
                    throw NetworkError.invalidResponse
                }
                
                guard Constants.successStatusCodes.contains(httpResponse.statusCode) else {
                    logger.error(
                        Constants.httpStatusCodeRejectedMessage,
                        metadata: [
                            AppLogMetadataKey.statusCode: String(httpResponse.statusCode),
                            AppLogMetadataKey.url: url.absoluteString
                        ]
                    )
                    throw makeNetworkError(from: httpResponse.statusCode)
                }
                
                logger.info(
                    Constants.httpRequestCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.statusCode: String(httpResponse.statusCode),
                        AppLogMetadataKey.url: url.absoluteString
                    ]
                )
                return data
            }
            .decode(type: Response.self, decoder: decoder)
            .mapError { [weak self] error in
                if let networkError = error as? NetworkError {
                    return networkError
                }
                
                if let urlError = error as? URLError {
                    return self?.makeNetworkError(from: urlError) ?? .operationFailed
                }
                
                if error is DecodingError {
                    self?.logger.error(
                        Constants.decodingFailedMessage,
                        metadata: [
                            AppLogMetadataKey.url: url.absoluteString
                        ]
                    )
                    return .parsingFailed
                }
                
                self?.logger.error(
                    Constants.publisherRequestFailedMessage,
                    metadata: [
                        AppLogMetadataKey.error: NetworkError.operationFailed.logDescription
                    ]
                )
                return .operationFailed
            }
            .eraseToAnyPublisher()
    }
    
    func makeNetworkError(from error: Error) -> NetworkError {
        guard let urlError = error as? URLError else {
            logger.error(
                Constants.urlErrorMappingFailedMessage,
                metadata: [
                    AppLogMetadataKey.error: Constants.unknownErrorReason
                ]
            )
            return .operationFailed
        }
        
        logger.error(
            Constants.urlErrorMappedMessage,
            metadata: [
                AppLogMetadataKey.statusCode: String(urlError.code.rawValue),
                AppLogMetadataKey.error: urlError.localizedDescription
            ]
        )
        
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternet
        case .cannotFindHost, .cannotConnectToHost, .timedOut:
            return .serviceUnavailable
        default:
            return .operationFailed
        }
    }
    
    func makeNetworkError(from statusCode: Int) -> NetworkError {
        if Constants.clientErrorStatusCodes.contains(statusCode) {
            logger.error(
                Constants.statusCodeMappedMessage,
                metadata: [
                    AppLogMetadataKey.statusCode: String(statusCode),
                    AppLogMetadataKey.error: NetworkError.accessDenied.logDescription
                ]
            )
            return .accessDenied
        }
        
        logger.error(
            Constants.statusCodeMappedMessage,
            metadata: [
                AppLogMetadataKey.statusCode: String(statusCode),
                AppLogMetadataKey.error: NetworkError.serverError.logDescription
            ]
        )
        return .serverError
    }
}

// MARK: - Constants
private extension NetworkService {
    enum Constants {
        static let apiBaseURL = "https://www.floatrates.com"
        static let dailyRatesPath = "/daily"
        static let pathSeparator = "/"
        static let jsonSuffix = ".json"
        static let currenciesBaseCurrencyCode = "USD"
        static let currenciesBaseCurrencyName = "U.S. Dollar"
        static let failedExchangeFileName = "p2p-exchange"
        static let getMethod = "GET"
        static let requestTimeout: TimeInterval = 15
        static let successStatusCodes = 200...299
        static let clientErrorStatusCodes = 400...499
        static let minimumRate: Float = 0
        static let apiLocaleIdentifier = "en_US_POSIX"
        static let apiLocale = Locale(identifier: apiLocaleIdentifier)
        static let combineStrategy = "combine"
        static let completionStrategy = "completion"
        static let currenciesRequestName = "currencies"
        static let rateRequestName = "rate"
        static let exchangeRequestName = "p2pExchange"
        static let currenciesRequestStartedMessage = "Currency network request was started."
        static let currenciesRequestCompletedMessage = "Currency network request was completed successfully."
        static let rateRequestStartedMessage = "Currency rate network request was started."
        static let rateRequestCompletedMessage = "Currency rate network request was completed successfully."
        static let exchangeRequestStartedMessage = "P2P exchange network request was started."
        static let exchangeRequestCompletedMessage = "P2P exchange network request was completed successfully."
        static let exchangeRequestFailedMessage = "P2P exchange network request failed."
        static let invalidURLMessage = "Network request URL creation failed."
        static let emptyCurrenciesResponseMessage = "Currency network response did not contain currencies."
        static let rateParsingFailedMessage = "Currency rate parsing failed."
        static let publisherRequestFailedMessage = "Publisher network request failed."
        static let httpRequestStartedMessage = "HTTP request was started."
        static let httpRequestCompletedMessage = "HTTP request was completed successfully."
        static let httpRequestFailedMessage = "HTTP request failed."
        static let invalidResponseMessage = "HTTP response was invalid."
        static let httpStatusCodeRejectedMessage = "HTTP status code was rejected."
        static let decodingFailedMessage = "HTTP response decoding failed."
        static let urlErrorMappingFailedMessage = "URL error mapping failed."
        static let urlErrorMappedMessage = "URL error was mapped to network error."
        static let statusCodeMappedMessage = "HTTP status code was mapped to network error."
        static let unknownErrorReason = "unknownError"
    }
}
