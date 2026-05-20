import XCTest
@testable import HW_19

final class P2PExchangeUseCaseTests: XCTestCase {
    // MARK: - Dependencies
    private var repository: P2PRepositoryMock!
    private var wallet: Wallet!
    private var useCase: P2PExchangeUseCase!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        
        repository = P2PRepositoryMock()
        wallet = Wallet(
            startBalance: P2PTestData.balancesByCode,
            startCredits: P2PTestData.emptyCredits
        )
        useCase = P2PExchangeUseCase(
            repository: repository,
            wallet: wallet
        )
    }
    
    override func tearDown() {
        useCase = nil
        wallet = nil
        repository = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testLoadCurrenciesUsesRepository() {
        var receivedCurrencies: [Currency] = []
        
        useCase.loadCurrencies { result in
            if case .success(let currencies) = result {
                receivedCurrencies = currencies
            }
        }
        
        XCTAssertEqual(repository.getCurrenciesCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(receivedCurrencies.count, P2PTestData.currencies.count)
    }
    
    func testLoadOffersUsesCurrencyCodes() {
        var receivedOffers: [P2POffer] = []
        
        useCase.loadOffers(
            sendCurrency: P2PTestData.sendCurrency,
            receiveCurrency: P2PTestData.receiveCurrency
        ) { result in
            if case .success(let offers) = result {
                receivedOffers = offers
            }
        }
        
        XCTAssertEqual(repository.getOffersCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(repository.lastSendCurrencyCode, P2PTestData.sendCurrency.code)
        XCTAssertEqual(repository.lastReceiveCurrencyCode, P2PTestData.receiveCurrency.code)
        XCTAssertEqual(receivedOffers.count, P2PTestData.expectedOffersCount)
    }
    
    func testPerformExchangeRejectsInvalidAmount() {
        var receivedError: P2PExchangeError?
        
        useCase.performExchange(
            offer: P2PTestData.offer,
            sendCurrency: P2PTestData.sendCurrency,
            receiveCurrency: P2PTestData.receiveCurrency,
            amountText: P2PTestData.invalidExchangeAmountText
        ) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        
        XCTAssertTrue(isInvalidAmount(receivedError))
        XCTAssertEqual(repository.performExchangeCallCount, Constants.defaultCallCount)
    }
    
    func testPerformExchangeRejectsEmptyAmount() {
        var receivedError: P2PExchangeError?
        
        useCase.performExchange(
            offer: P2PTestData.offer,
            sendCurrency: P2PTestData.sendCurrency,
            receiveCurrency: P2PTestData.receiveCurrency,
            amountText: P2PTestData.emptyExchangeAmountText
        ) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        
        XCTAssertTrue(isInvalidAmount(receivedError))
        XCTAssertEqual(repository.performExchangeCallCount, Constants.defaultCallCount)
    }
    
    func testPerformExchangeRejectsLowBalance() {
        var receivedError: P2PExchangeError?
        
        useCase.performExchange(
            offer: P2PTestData.offer,
            sendCurrency: P2PTestData.sendCurrency,
            receiveCurrency: P2PTestData.receiveCurrency,
            amountText: P2PTestData.highExchangeAmountText
        ) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        
        XCTAssertTrue(isNotEnoughMoney(receivedError))
        XCTAssertEqual(repository.performExchangeCallCount, Constants.defaultCallCount)
    }
    
    func testPerformExchangeRejectsLowReserve() {
        let offer = P2POffer(
            id: P2PTestData.offer.id,
            sellerName: P2PTestData.offer.sellerName,
            rate: P2PTestData.offer.rate,
            reserve: P2PTestData.lowBalance,
            receiveCurrencyCode: P2PTestData.offer.receiveCurrencyCode
        )
        var receivedError: P2PExchangeError?
        
        useCase.performExchange(
            offer: offer,
            sendCurrency: P2PTestData.sendCurrency,
            receiveCurrency: P2PTestData.receiveCurrency,
            amountText: P2PTestData.exchangeAmountText
        ) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        
        XCTAssertTrue(isReserveIsTooLow(receivedError))
        XCTAssertEqual(repository.performExchangeCallCount, Constants.defaultCallCount)
    }
    
    func testPerformExchangeUsesRepositoryAndUpdatesWallet() throws {
        var receivedResult: P2PExchangeResult?
        
        useCase.performExchange(
            offer: P2PTestData.offer,
            sendCurrency: P2PTestData.sendCurrency,
            receiveCurrency: P2PTestData.receiveCurrency,
            amountText: P2PTestData.exchangeAmountTextWithComma
        ) { result in
            if case .success(let exchangeResult) = result {
                receivedResult = exchangeResult
            }
        }
        
        let sendAmount = try XCTUnwrap(repository.lastSendAmount)
        let receiveAmount = try XCTUnwrap(repository.lastReceiveAmount)
        let exchangeResult = try XCTUnwrap(receivedResult)
        
        XCTAssertEqual(repository.performExchangeCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(repository.lastSendCurrencyCode, P2PTestData.sendCurrency.code)
        XCTAssertEqual(repository.lastReceiveCurrencyCode, P2PTestData.receiveCurrency.code)
        XCTAssertEqual(sendAmount, P2PTestData.exchangeSendAmount, accuracy: P2PTestData.accuracy)
        XCTAssertEqual(receiveAmount, P2PTestData.exchangeReceiveAmount, accuracy: P2PTestData.accuracy)
        XCTAssertEqual(exchangeResult.sendAmount, P2PTestData.exchangeResult.sendAmount, accuracy: P2PTestData.accuracy)
        XCTAssertEqual(
            useCase.balance(for: P2PTestData.sendCurrency.code),
            P2PTestData.initialSendBalance - P2PTestData.exchangeSendAmount,
            accuracy: P2PTestData.accuracy
        )
        XCTAssertEqual(
            useCase.balance(for: P2PTestData.receiveCurrency.code),
            P2PTestData.initialReceiveBalance + P2PTestData.exchangeReceiveAmount,
            accuracy: P2PTestData.accuracy
        )
    }
    
    func testPerformExchangeMapsRepositoryFailure() {
        repository.performExchangeResult = .failure(P2PTestData.networkError)
        var receivedError: P2PExchangeError?
        
        useCase.performExchange(
            offer: P2PTestData.offer,
            sendCurrency: P2PTestData.sendCurrency,
            receiveCurrency: P2PTestData.receiveCurrency,
            amountText: P2PTestData.exchangeAmountText
        ) { result in
            if case .failure(let error) = result {
                receivedError = error
            }
        }
        
        XCTAssertTrue(isNetworkNoInternet(receivedError))
    }
}

// MARK: - Private Methods
private extension P2PExchangeUseCaseTests {
    func isInvalidAmount(_ error: P2PExchangeError?) -> Bool {
        guard case .invalidAmount = error else { return false }
        
        return true
    }
    
    func isNotEnoughMoney(_ error: P2PExchangeError?) -> Bool {
        guard case .notEnoughMoney = error else { return false }
        
        return true
    }
    
    func isReserveIsTooLow(_ error: P2PExchangeError?) -> Bool {
        guard case .reserveIsTooLow = error else { return false }
        
        return true
    }
    
    func isNetworkNoInternet(_ error: P2PExchangeError?) -> Bool {
        guard case .network(.noInternet) = error else { return false }
        
        return true
    }
}

// MARK: - Constants
private extension P2PExchangeUseCaseTests {
    enum Constants {
        static let defaultCallCount = 0
    }
}
