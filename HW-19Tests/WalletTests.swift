import XCTest
@testable import HW_19

final class WalletTests: XCTestCase {
    // MARK: - Dependencies
    private var wallet: Wallet!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        
        wallet = Wallet(
            startBalance: P2PTestData.balancesByCode,
            startCredits: P2PTestData.emptyCredits
        )
    }
    
    override func tearDown() {
        wallet = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testExchangeMovesBalanceBetweenCurrencies() {
        let isCompleted = wallet.exchange(
            sendCurrencyCode: P2PTestData.sendCurrency.code,
            receiveCurrencyCode: P2PTestData.receiveCurrency.code,
            sendAmount: P2PTestData.exchangeSendAmount,
            receiveAmount: P2PTestData.exchangeReceiveAmount
        )
        
        XCTAssertTrue(isCompleted)
        XCTAssertEqual(
            wallet.balance(for: P2PTestData.sendCurrency.code),
            P2PTestData.initialSendBalance - P2PTestData.exchangeSendAmount,
            accuracy: P2PTestData.accuracy
        )
        XCTAssertEqual(
            wallet.balance(for: P2PTestData.receiveCurrency.code),
            P2PTestData.initialReceiveBalance + P2PTestData.exchangeReceiveAmount,
            accuracy: P2PTestData.accuracy
        )
    }
    
    func testExchangeRejectsLowBalance() {
        let isCompleted = wallet.exchange(
            sendCurrencyCode: P2PTestData.sendCurrency.code,
            receiveCurrencyCode: P2PTestData.receiveCurrency.code,
            sendAmount: P2PTestData.initialSendBalance + P2PTestData.exchangeSendAmount,
            receiveAmount: P2PTestData.exchangeReceiveAmount
        )
        
        XCTAssertFalse(isCompleted)
        XCTAssertEqual(
            wallet.balance(for: P2PTestData.sendCurrency.code),
            P2PTestData.initialSendBalance,
            accuracy: P2PTestData.accuracy
        )
    }
}
