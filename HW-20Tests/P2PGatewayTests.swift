import XCTest
@testable import HW_20

final class P2PGatewayTests: XCTestCase {
    // MARK: - Dependencies
    private var networkService: NetworkServiceMock!
    private var gateway: P2PGateway!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        
        networkService = NetworkServiceMock()
        gateway = P2PGateway(networkService: networkService)
    }
    
    override func tearDown() {
        gateway = nil
        networkService = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testFetchCurrenciesUsesNetworkService() {
        var receivedCurrencies: [APICurrency] = []
        
        gateway.fetchCurrencies { result in
            if case .success(let currencies) = result {
                receivedCurrencies = currencies
            }
        }
        
        XCTAssertEqual(networkService.fetchCurrenciesCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(receivedCurrencies.count, P2PTestData.apiCurrencies.count)
        XCTAssertEqual(receivedCurrencies.first?.code, P2PTestData.apiSendCurrency.code)
    }
    
    func testFetchRateUsesNetworkService() {
        var receivedRate: CurrencyPairRateDTO?
        
        gateway.fetchRate(
            from: P2PTestData.sendCurrency.code,
            to: P2PTestData.receiveCurrency.code
        ) { result in
            if case .success(let rate) = result {
                receivedRate = rate
            }
        }
        
        XCTAssertEqual(networkService.fetchRateCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(networkService.lastBaseCode, P2PTestData.sendCurrency.code)
        XCTAssertEqual(networkService.lastQuoteCode, P2PTestData.receiveCurrency.code)
        XCTAssertEqual(receivedRate?.base, P2PTestData.rateDTO.base)
        XCTAssertEqual(receivedRate?.quote, P2PTestData.rateDTO.quote)
    }
    
    func testPerformExchangeUsesNetworkService() {
        var receivedResult: P2PExchangeResult?
        
        gateway.performExchange(request: P2PTestData.exchangeRequest) { result in
            if case .success(let exchangeResult) = result {
                receivedResult = exchangeResult
            }
        }
        
        XCTAssertEqual(networkService.performExchangeCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(networkService.lastRequest?.offer.id, P2PTestData.exchangeRequest.offer.id)
        XCTAssertEqual(networkService.lastRequest?.sendCurrencyCode, P2PTestData.exchangeRequest.sendCurrencyCode)
        XCTAssertEqual(receivedResult?.sendCurrencyCode, P2PTestData.exchangeResult.sendCurrencyCode)
        XCTAssertEqual(receivedResult?.receiveCurrencyCode, P2PTestData.exchangeResult.receiveCurrencyCode)
    }
    
    func testFetchCurrenciesForwardsFailure() {
        networkService.fetchCurrenciesResult = .failure(P2PTestData.networkError)
        var receivedError: NetworkError?
        
        gateway.fetchCurrencies { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        
        XCTAssertEqual(networkService.fetchCurrenciesCallCount, P2PTestData.expectedCallCount)
        XCTAssertTrue(isNoInternet(receivedError))
    }
}

// MARK: - Private Methods
private extension P2PGatewayTests {
    func isNoInternet(_ error: NetworkError?) -> Bool {
        guard case .noInternet = error else { return false }
        
        return true
    }
}
