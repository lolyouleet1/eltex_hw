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
    
    // MARK: - State
    var isNetworkWithCombine: Bool
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        isNetworkWithCombine: Bool = AppConfiguration.Network.isNetworkWithCombine
    ) {
        self.session = session
        self.decoder = decoder
        self.isNetworkWithCombine = isNetworkWithCombine
    }
    
    // MARK: - Public Methods
    func fetchCurrencies(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void) {
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
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return performRequestPublisher(url: url)
            .tryMap { [weak self] (response: [String: FloatRatesRateDTO]) -> [APICurrency] in
                guard let self else {
                    throw NetworkError.operationFailed
                }
                
                let currencies = makeCurrencies(from: response)
                guard !currencies.isEmpty else {
                    throw NetworkError.parsingFailed
                }
                
                return currencies
            }
            .mapError { error in
                error as? NetworkError ?? .operationFailed
            }
            .eraseToAnyPublisher()
    }
    
    func fetchRate(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void) {
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
                    throw NetworkError.parsingFailed
                }
                
                return rate
            }
            .mapError { error in
                error as? NetworkError ?? .operationFailed
            }
            .eraseToAnyPublisher()
    }
    
    func performP2PExchange(request: P2PExchangeRequest, completion: @escaping (Result<P2PExchangeResult, NetworkError>) -> Void) {
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
            
            return Just(result)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        guard let url = makeFailedExchangeURL() else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        return performRequestPublisher(url: url)
            .flatMap { (_: [String: FloatRatesRateDTO]) -> AnyPublisher<P2PExchangeResult, NetworkError> in
                Fail(error: .operationFailed).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Private Methods
private extension NetworkService {
    func fetchCurrenciesWithCompletion(completion: @escaping (Result<[APICurrency], NetworkError>) -> Void) {
        guard let url = makeDailyRatesURL(for: Constants.currenciesBaseCurrencyCode) else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url) { [weak self] (result: Result<[String: FloatRatesRateDTO], NetworkError>) in
            guard let self else { return }
            
            switch result {
            case .success(let response):
                let currencies = makeCurrencies(from: response)
                guard !currencies.isEmpty else {
                    completion(.failure(.parsingFailed))
                    return
                }
                
                completion(.success(currencies))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchRateWithCompletion(from baseCode: String, to quoteCode: String, completion: @escaping (Result<CurrencyPairRateDTO, NetworkError>) -> Void) {
        guard let url = makeDailyRatesURL(for: baseCode) else {
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
                    completion(.failure(.parsingFailed))
                    return
                }
                
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
            
            completion(.success(result))
            return
        }
        
        guard let url = makeFailedExchangeURL() else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url) { (result: Result<[String: FloatRatesRateDTO], NetworkError>) in
            switch result {
            case .success:
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
        
        session.dataTask(with: request) { [weak self] data, response, error in
            guard let self else { return }
            
            if let error = error {
                completion(.failure(makeNetworkError(from: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard Constants.successStatusCodes.contains(httpResponse.statusCode) else {
                completion(.failure(makeNetworkError(from: httpResponse.statusCode)))
                return
            }
            
            guard let data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let response = try decoder.decode(Response.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.parsingFailed))
            }
        }.resume()
    }
    
    func performRequestPublisher<Response: Decodable>(url: URL) -> AnyPublisher<Response, NetworkError> {
        let request = makeRequest(url: url)
        
        return session.dataTaskPublisher(for: request)
            .mapError { [weak self] error in
                self?.makeNetworkError(from: error) ?? .operationFailed
            }
            .tryMap { [weak self] data, response -> Data in
                guard let self else {
                    throw NetworkError.operationFailed
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                
                guard Constants.successStatusCodes.contains(httpResponse.statusCode) else {
                    throw makeNetworkError(from: httpResponse.statusCode)
                }
                
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
                    return .parsingFailed
                }
                
                return .operationFailed
            }
            .eraseToAnyPublisher()
    }
    
    func makeNetworkError(from error: Error) -> NetworkError {
        guard let urlError = error as? URLError else {
            return .operationFailed
        }
        
        print("\(Constants.urlErrorLogPrefix)\(urlError.code.rawValue), \(urlError.localizedDescription)")
        
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
            return .accessDenied
        }
        
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
        static let urlErrorLogPrefix = "NetworkService URLError: "
        static let successStatusCodes = 200...299
        static let clientErrorStatusCodes = 400...499
        static let minimumRate: Float = 0
        static let apiLocaleIdentifier = "en_US_POSIX"
        static let apiLocale = Locale(identifier: apiLocaleIdentifier)
    }
}
