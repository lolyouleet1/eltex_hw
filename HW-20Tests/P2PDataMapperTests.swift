import XCTest
@testable import HW_20

final class P2PDataMapperTests: XCTestCase {
    // MARK: - Dependencies
    private var mapper: P2PDataMapper!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        
        mapper = P2PDataMapper()
    }
    
    override func tearDown() {
        mapper = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testMakeCurrenciesMapsAPICurrencies() throws {
        let currencies = mapper.makeCurrencies(from: P2PTestData.apiCurrencies)
        let currency = try XCTUnwrap(currencies.first)
        
        XCTAssertEqual(currencies.count, P2PTestData.apiCurrencies.count)
        XCTAssertEqual(currency.id, P2PTestData.apiSendCurrency.id)
        XCTAssertEqual(currency.code, P2PTestData.apiSendCurrency.code)
        XCTAssertEqual(currency.baseValue, P2PTestData.sendCurrency.baseValue, accuracy: P2PTestData.accuracy)
        XCTAssertEqual(currency.type, P2PTestData.sendCurrency.type)
        XCTAssertEqual(currency.isFavorite, P2PTestData.sendCurrency.isFavorite)
    }
    
    func testMakeRateMapsDTO() {
        let rate = mapper.makeRate(from: P2PTestData.rateDTO)
        
        XCTAssertEqual(rate.baseCurrencyCode, P2PTestData.currencyPairRate.baseCurrencyCode)
        XCTAssertEqual(rate.receiveCurrencyCode, P2PTestData.currencyPairRate.receiveCurrencyCode)
        XCTAssertEqual(rate.rate, P2PTestData.currencyPairRate.rate, accuracy: P2PTestData.accuracy)
    }
    
    func testMakeExchangeRequestMapsValues() {
        let request = mapper.makeExchangeRequest(
            offer: P2PTestData.offer,
            sendCurrencyCode: P2PTestData.sendCurrency.code,
            receiveCurrencyCode: P2PTestData.receiveCurrency.code,
            sendAmount: P2PTestData.exchangeSendAmount,
            receiveAmount: P2PTestData.exchangeReceiveAmount
        )
        
        XCTAssertEqual(request.offer.id, P2PTestData.offer.id)
        XCTAssertEqual(request.sendCurrencyCode, P2PTestData.exchangeRequest.sendCurrencyCode)
        XCTAssertEqual(request.receiveCurrencyCode, P2PTestData.exchangeRequest.receiveCurrencyCode)
        XCTAssertEqual(request.sendAmount, P2PTestData.exchangeRequest.sendAmount, accuracy: P2PTestData.accuracy)
        XCTAssertEqual(request.receiveAmount, P2PTestData.exchangeRequest.receiveAmount, accuracy: P2PTestData.accuracy)
    }
}
