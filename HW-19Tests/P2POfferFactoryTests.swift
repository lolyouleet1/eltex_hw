import XCTest
@testable import HW_19

final class P2POfferFactoryTests: XCTestCase {
    // MARK: - Dependencies
    private var factory: P2POfferFactory!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        
        factory = P2POfferFactory()
    }
    
    override func tearDown() {
        factory = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testMakeOffersBuildsSortedOffersForReceiveCurrency() {
        let offers = factory.makeOffers(
            rate: P2PTestData.offer.rate,
            receiveCurrencyCode: P2PTestData.receiveCurrency.code
        )
        
        XCTAssertEqual(offers.count, P2PTestData.expectedFactoryOffersCount)
        XCTAssertTrue(offers.allSatisfy { $0.receiveCurrencyCode == P2PTestData.receiveCurrency.code })
        XCTAssertTrue(zip(offers, offers.dropFirst()).allSatisfy { $0.rate >= $1.rate })
    }
}
