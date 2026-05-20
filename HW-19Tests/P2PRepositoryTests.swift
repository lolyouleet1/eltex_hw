import XCTest
@testable import HW_19

final class P2PRepositoryTests: XCTestCase {
    // MARK: - Dependencies
    private var gateway: P2PGatewayMock!
    private var repository: P2PRepository!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        
        gateway = P2PGatewayMock()
        repository = P2PRepository(
            gateway: gateway,
            dataMapper: P2PDataMapper(),
            offerFactory: P2POfferFactory()
        )
    }
    
    override func tearDown() {
        repository = nil
        gateway = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testGetCurrenciesMapsGatewayCurrencies() throws {
        var receivedCurrencies: [Currency] = []
        
        repository.getCurrencies { result in
            if case .success(let currencies) = result {
                receivedCurrencies = currencies
            }
        }
        
        let currency = try XCTUnwrap(receivedCurrencies.first)
        
        XCTAssertEqual(gateway.fetchCurrenciesCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(receivedCurrencies.count, P2PTestData.apiCurrencies.count)
        XCTAssertEqual(currency.id, P2PTestData.apiSendCurrency.id)
        XCTAssertEqual(currency.code, P2PTestData.apiSendCurrency.code)
        XCTAssertEqual(currency.baseValue, P2PTestData.sendCurrency.baseValue, accuracy: P2PTestData.accuracy)
    }
    
    func testGetOffersFetchesRateAndBuildsOffers() {
        var receivedOffers: [P2POffer] = []
        
        repository.getOffers(
            sendCurrencyCode: P2PTestData.sendCurrency.code,
            receiveCurrencyCode: P2PTestData.receiveCurrency.code
        ) { result in
            if case .success(let offers) = result {
                receivedOffers = offers
            }
        }
        
        XCTAssertEqual(gateway.fetchRateCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(gateway.lastBaseCode, P2PTestData.sendCurrency.code)
        XCTAssertEqual(gateway.lastQuoteCode, P2PTestData.receiveCurrency.code)
        XCTAssertEqual(receivedOffers.count, P2PTestData.expectedFactoryOffersCount)
        XCTAssertTrue(receivedOffers.allSatisfy { $0.receiveCurrencyCode == P2PTestData.receiveCurrency.code })
        XCTAssertTrue(zip(receivedOffers, receivedOffers.dropFirst()).allSatisfy { $0.rate >= $1.rate })
    }
    
    func testPerformExchangeMapsRequestAndUsesGateway() throws {
        var receivedResult: P2PExchangeResult?
        
        repository.performExchange(
            offer: P2PTestData.offer,
            sendCurrencyCode: P2PTestData.sendCurrency.code,
            receiveCurrencyCode: P2PTestData.receiveCurrency.code,
            sendAmount: P2PTestData.exchangeSendAmount,
            receiveAmount: P2PTestData.exchangeReceiveAmount
        ) { result in
            if case .success(let exchangeResult) = result {
                receivedResult = exchangeResult
            }
        }
        
        let request = try XCTUnwrap(gateway.lastRequest)
        
        XCTAssertEqual(gateway.performExchangeCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(request.offer.id, P2PTestData.offer.id)
        XCTAssertEqual(request.sendCurrencyCode, P2PTestData.exchangeRequest.sendCurrencyCode)
        XCTAssertEqual(request.receiveCurrencyCode, P2PTestData.exchangeRequest.receiveCurrencyCode)
        XCTAssertEqual(request.sendAmount, P2PTestData.exchangeRequest.sendAmount, accuracy: P2PTestData.accuracy)
        XCTAssertEqual(request.receiveAmount, P2PTestData.exchangeRequest.receiveAmount, accuracy: P2PTestData.accuracy)
        XCTAssertEqual(receivedResult?.sendCurrencyCode, P2PTestData.exchangeResult.sendCurrencyCode)
    }
    
    func testGetCurrenciesForwardsGatewayFailure() {
        gateway.fetchCurrenciesResult = .failure(P2PTestData.networkError)
        var receivedError: NetworkError?
        
        repository.getCurrencies { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        
        XCTAssertTrue(isNoInternet(receivedError))
    }
}

// MARK: - Private Methods
private extension P2PRepositoryTests {
    func isNoInternet(_ error: NetworkError?) -> Bool {
        guard case .noInternet = error else { return false }
        
        return true
    }
}
