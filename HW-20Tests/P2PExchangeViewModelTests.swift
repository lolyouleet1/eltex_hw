import XCTest
@testable import HW_20

final class P2PExchangeViewModelTests: XCTestCase {
    // MARK: - Dependencies
    private var useCase: P2PExchangeUseCaseMock!
    private var currencySelectionService: CurrencySelectionService!
    private var viewModel: P2PExchangeViewModel!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        
        useCase = P2PExchangeUseCaseMock()
        currencySelectionService = CurrencySelectionService()
        viewModel = P2PExchangeViewModel(
            exchangeUseCase: useCase,
            currencySelectionService: currencySelectionService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        currencySelectionService = nil
        useCase = nil
        
        super.tearDown()
    }
    
    // MARK: - Tests
    func testInitialStateUsesDefaultValues() {
        XCTAssertTrue(viewModel.viewState.offers.isEmpty)
        XCTAssertTrue(viewModel.viewState.isTableHidden)
        XCTAssertFalse(viewModel.viewState.isLoading)
        XCTAssertEqual(viewModel.viewState.emptyStateText, P2PTestData.defaultEmptyStateText)
        XCTAssertEqual(viewModel.viewState.leftCurrencyText, P2PTestData.defaultCurrencyText)
        XCTAssertEqual(viewModel.viewState.rightCurrencyText, P2PTestData.defaultCurrencyText)
        XCTAssertEqual(viewModel.viewState.sendBalanceText, P2PTestData.defaultSendBalanceText)
        XCTAssertEqual(viewModel.viewState.receiveBalanceText, P2PTestData.defaultReceiveBalanceText)
    }
    
    func testStartLoadsDefaultCurrencyPairAndOffers() throws {
        let state = startViewModel()
        let offer = try XCTUnwrap(state.offers.first)
        
        XCTAssertEqual(useCase.loadCurrenciesCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(useCase.loadOffersCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(useCase.lastSendCurrency?.code, P2PTestData.sendCurrency.code)
        XCTAssertEqual(useCase.lastReceiveCurrency?.code, P2PTestData.receiveCurrency.code)
        XCTAssertEqual(state.offers.count, P2PTestData.expectedOffersCount)
        XCTAssertFalse(state.isTableHidden)
        XCTAssertFalse(state.isLoading)
        XCTAssertEqual(state.leftCurrencyText, P2PTestData.sendCurrency.code)
        XCTAssertEqual(state.rightCurrencyText, P2PTestData.receiveCurrency.code)
        XCTAssertEqual(state.sendBalanceText, P2PTestData.sendBalanceText)
        XCTAssertEqual(state.receiveBalanceText, P2PTestData.receiveBalanceText)
        XCTAssertEqual(offer.sellerText, P2PTestData.offer.sellerName)
        XCTAssertEqual(offer.rateText, P2PTestData.offerRateText)
        XCTAssertEqual(offer.reserveText, P2PTestData.offerReserveText)
    }
    
    func testStartRunsOnce() {
        _ = startViewModel()
        
        viewModel.start()
        
        XCTAssertEqual(useCase.loadCurrenciesCallCount, P2PTestData.expectedCallCount)
    }
    
    func testStartFailureShowsAlert() {
        useCase.loadCurrenciesResult = .failure(P2PTestData.networkError)
        
        let alert = waitForAlert {
            viewModel.start()
        }
        
        XCTAssertEqual(useCase.loadCurrenciesCallCount, P2PTestData.expectedCallCount)
        XCTAssertTrue(viewModel.viewState.isTableHidden)
        XCTAssertFalse(viewModel.viewState.isLoading)
        XCTAssertEqual(viewModel.viewState.emptyStateText, P2PTestData.defaultEmptyStateText)
        XCTAssertEqual(alert.title, P2PTestData.noInternetAlertTitle)
        XCTAssertEqual(alert.message, P2PTestData.noInternetAlertMessage)
    }
    
    func testStartWithEmptyOffersShowsEmptyState() {
        useCase.loadOffersResult = .success(P2PTestData.emptyOffers)
        
        let state = waitForState {
            viewModel.start()
        } condition: {
            $0.emptyStateText == P2PTestData.noOffersText && !$0.isLoading
        }
        
        XCTAssertTrue(state.offers.isEmpty)
        XCTAssertTrue(state.isTableHidden)
        XCTAssertEqual(state.emptyStateText, P2PTestData.noOffersText)
    }
    
    func testStartWithOffersFailureShowsAlert() {
        useCase.loadOffersResult = .failure(P2PTestData.networkError)
        
        let alert = waitForAlert {
            viewModel.start()
        }
        
        XCTAssertEqual(useCase.loadOffersCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(viewModel.viewState.emptyStateText, P2PTestData.noOffersText)
        XCTAssertEqual(alert.title, P2PTestData.noInternetAlertTitle)
        XCTAssertEqual(alert.message, P2PTestData.noInternetAlertMessage)
    }
    
    func testHandleCurrencySelectionLoadsOffersForSelectedPair() {
        _ = startViewModel()
        
        let state = waitForState {
            viewModel.handleCurrencySelection(P2PTestData.alternateCurrency, for: .left)
        } condition: {
            $0.leftCurrencyText == P2PTestData.alternateCurrency.code && !$0.isLoading
        }
        
        XCTAssertEqual(useCase.loadOffersCallCount, P2PTestData.secondCallCount)
        XCTAssertEqual(useCase.lastSendCurrency?.code, P2PTestData.alternateCurrency.code)
        XCTAssertEqual(useCase.lastReceiveCurrency?.code, P2PTestData.receiveCurrency.code)
        XCTAssertEqual(state.leftCurrencyText, P2PTestData.alternateCurrency.code)
        XCTAssertEqual(state.rightCurrencyText, P2PTestData.receiveCurrency.code)
        XCTAssertEqual(state.sendBalanceText, P2PTestData.alternateSendBalanceText)
    }
    
    func testOfferAtIndexReturnsOffer() throws {
        _ = startViewModel()
        
        let offer = try XCTUnwrap(viewModel.offer(at: Constants.firstOfferIndex))
        
        XCTAssertEqual(offer.id, P2PTestData.offer.id)
    }
    
    func testOfferAtInvalidIndexReturnsNil() {
        _ = startViewModel()
        
        XCTAssertNil(viewModel.offer(at: Constants.invalidOfferIndex))
    }
    
    func testExchangeInputViewModelReturnsSelectedOfferData() throws {
        _ = startViewModel()
        
        let inputViewModel = try XCTUnwrap(
            viewModel.exchangeInputViewModel(for: Constants.firstOfferIndex)
        )
        
        XCTAssertEqual(inputViewModel.title, P2PTestData.exchangeInputTitle)
        XCTAssertEqual(inputViewModel.message, P2PTestData.exchangeInputMessage)
        XCTAssertEqual(inputViewModel.placeholder, P2PTestData.exchangeInputPlaceholder)
        XCTAssertEqual(inputViewModel.actionTitle, P2PTestData.exchangeInputActionTitle)
        XCTAssertEqual(inputViewModel.cancelTitle, P2PTestData.exchangeInputCancelTitle)
    }
    
    func testPerformExchangeSuccessShowsAlert() {
        _ = startViewModel()
        
        let alert = waitForAlert {
            viewModel.performExchange(
                offerIndex: Constants.firstOfferIndex,
                amountText: P2PTestData.exchangeAmountText
            )
        }
        
        XCTAssertEqual(useCase.performExchangeCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(useCase.lastOffer?.id, P2PTestData.offer.id)
        XCTAssertEqual(useCase.lastAmountText, P2PTestData.exchangeAmountText)
        XCTAssertEqual(alert.title, P2PTestData.successAlertTitle)
        XCTAssertEqual(alert.message, P2PTestData.successAlertMessage)
        XCTAssertEqual(viewModel.viewState.offers.count, P2PTestData.expectedOffersCount)
    }
    
    func testPerformExchangeFailureShowsAlert() {
        _ = startViewModel()
        useCase.performExchangeResult = .failure(P2PTestData.exchangeError)
        
        let alert = waitForAlert {
            viewModel.performExchange(
                offerIndex: Constants.firstOfferIndex,
                amountText: P2PTestData.exchangeAmountText
            )
        }
        
        XCTAssertEqual(useCase.performExchangeCallCount, P2PTestData.expectedCallCount)
        XCTAssertEqual(alert.title, P2PTestData.notEnoughMoneyAlertTitle)
        XCTAssertEqual(alert.message, P2PTestData.notEnoughMoneyAlertMessage)
    }
}

// MARK: - Private Methods
private extension P2PExchangeViewModelTests {
    func startViewModel() -> P2PExchangeViewModel.ViewState {
        waitForState {
            viewModel.start()
        } condition: {
            $0.offers.count == P2PTestData.expectedOffersCount && !$0.isLoading
        }
    }
    
    func waitForState(
        action: () -> Void,
        condition: @escaping (P2PExchangeViewModel.ViewState) -> Bool
    ) -> P2PExchangeViewModel.ViewState {
        let expectation = expectation(description: Constants.stateExpectationDescription)
        var expectedState: P2PExchangeViewModel.ViewState?
        var didReceiveExpectedState = false
        
        viewModel.onStateChange = { state in
            guard !didReceiveExpectedState,
                  condition(state) else { return }
            
            didReceiveExpectedState = true
            expectedState = state
            expectation.fulfill()
        }
        
        action()
        wait(for: [expectation], timeout: P2PTestData.waitTimeout)
        
        return expectedState ?? viewModel.viewState
    }
    
    func waitForAlert(action: () -> Void) -> P2PAlertViewModel {
        let expectation = expectation(description: Constants.alertExpectationDescription)
        var expectedAlert: P2PAlertViewModel?
        
        viewModel.onAlert = { alert in
            expectedAlert = alert
            expectation.fulfill()
        }
        
        action()
        wait(for: [expectation], timeout: P2PTestData.waitTimeout)
        
        return expectedAlert ?? P2PAlertViewModel(
            title: Constants.emptyText,
            message: Constants.emptyText
        )
    }
}

// MARK: - Constants
private extension P2PExchangeViewModelTests {
    enum Constants {
        static let firstOfferIndex = 0
        static let invalidOfferIndex = -1
        static let stateExpectationDescription = "State"
        static let alertExpectationDescription = "Alert"
        static let emptyText = ""
    }
}
