import Foundation

protocol P2PExchangeUseCaseProtocol: AnyObject {
    func loadCurrencies(completion: @escaping (Result<[Currency], NetworkError>) -> Void)
    func loadOffers(sendCurrency: Currency, receiveCurrency: Currency, completion: @escaping (Result<[P2POffer], NetworkError>) -> Void)
    func performExchange(
        offer: P2POffer,
        sendCurrency: Currency,
        receiveCurrency: Currency,
        amountText: String?,
        completion: @escaping (Result<P2PExchangeResult, P2PExchangeError>) -> Void
    )
    func balance(for currencyCode: String) -> Float
}

enum P2PExchangeError: Error {
    case invalidAmount
    case notEnoughMoney
    case reserveIsTooLow
    case network(NetworkError)
    case operationFailed
}

final class P2PExchangeUseCase: P2PExchangeUseCaseProtocol {
    // MARK: - Dependencies
    private let repository: P2PRepositoryProtocol
    private let wallet: Wallet
    private let logger: AppLoggerProtocol
    
    // MARK: - Lifecycle
    init(
        repository: P2PRepositoryProtocol,
        wallet: Wallet,
        logger: AppLoggerProtocol = AppLogger.p2pTrading
    ) {
        self.repository = repository
        self.wallet = wallet
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func loadCurrencies(completion: @escaping (Result<[Currency], NetworkError>) -> Void) {
        logger.info(Constants.currencyLoadingRequestedMessage)
        repository.getCurrencies(completion: completion)
    }
    
    func loadOffers(sendCurrency: Currency, receiveCurrency: Currency, completion: @escaping (Result<[P2POffer], NetworkError>) -> Void) {
        logger.info(
            Constants.offerLoadingRequestedMessage,
            metadata: [
                AppLogMetadataKey.baseCurrency: sendCurrency.code,
                AppLogMetadataKey.quoteCurrency: receiveCurrency.code
            ]
        )
        repository.getOffers(
            sendCurrencyCode: sendCurrency.code,
            receiveCurrencyCode: receiveCurrency.code,
            completion: completion
        )
    }
    
    func performExchange(
        offer: P2POffer,
        sendCurrency: Currency,
        receiveCurrency: Currency,
        amountText: String?,
        completion: @escaping (Result<P2PExchangeResult, P2PExchangeError>) -> Void
    ) {
        guard let sendAmount = makeAmount(from: amountText),
              sendAmount > Constants.minimumAmount else {
            logger.warning(
                Constants.exchangeValidationFailedMessage,
                metadata: [
                    AppLogMetadataKey.error: P2PExchangeError.invalidAmount.logDescription
                ]
            )
            completion(.failure(.invalidAmount))
            return
        }
        
        guard wallet.balance(for: sendCurrency.code) >= sendAmount else {
            logger.warning(
                Constants.exchangeValidationFailedMessage,
                metadata: [
                    AppLogMetadataKey.error: P2PExchangeError.notEnoughMoney.logDescription,
                    AppLogMetadataKey.sendAmount: AppConfiguration.PriceFormatting.string(from: sendAmount),
                    AppLogMetadataKey.sendCurrency: sendCurrency.code
                ]
            )
            completion(.failure(.notEnoughMoney))
            return
        }
        
        let receiveAmount = AppConfiguration.PriceFormatting.rounded(sendAmount * offer.rate)
        guard receiveAmount <= offer.reserve else {
            logger.warning(
                Constants.exchangeValidationFailedMessage,
                metadata: [
                    AppLogMetadataKey.error: P2PExchangeError.reserveIsTooLow.logDescription,
                    AppLogMetadataKey.receiveAmount: AppConfiguration.PriceFormatting.string(from: receiveAmount),
                    AppLogMetadataKey.reserve: AppConfiguration.PriceFormatting.string(from: offer.reserve)
                ]
            )
            completion(.failure(.reserveIsTooLow))
            return
        }
        
        logger.info(
            Constants.exchangeRepositoryRequestStartedMessage,
            metadata: [
                AppLogMetadataKey.offerID: offer.id.uuidString,
                AppLogMetadataKey.sendAmount: AppConfiguration.PriceFormatting.string(from: sendAmount),
                AppLogMetadataKey.sendCurrency: sendCurrency.code,
                AppLogMetadataKey.receiveAmount: AppConfiguration.PriceFormatting.string(from: receiveAmount),
                AppLogMetadataKey.receiveCurrency: receiveCurrency.code
            ]
        )
        repository.performExchange(
            offer: offer,
            sendCurrencyCode: sendCurrency.code,
            receiveCurrencyCode: receiveCurrency.code,
            sendAmount: sendAmount,
            receiveAmount: receiveAmount
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let result):
                handleExchangeResult(result, completion: completion)
            case .failure(let error):
                logger.error(
                    Constants.exchangeRepositoryRequestFailedMessage,
                    metadata: [
                        AppLogMetadataKey.error: error.logDescription
                    ]
                )
                completion(.failure(.network(error)))
            }
        }
    }
    
    func balance(for currencyCode: String) -> Float {
        wallet.balance(for: currencyCode)
    }
}

// MARK: - Private Methods
private extension P2PExchangeUseCase {
    func handleExchangeResult(
        _ result: P2PExchangeResult,
        completion: @escaping (Result<P2PExchangeResult, P2PExchangeError>) -> Void
    ) {
        let isCompleted = wallet.exchange(
            sendCurrencyCode: result.sendCurrencyCode,
            receiveCurrencyCode: result.receiveCurrencyCode,
            sendAmount: result.sendAmount,
            receiveAmount: result.receiveAmount
        )
        
        if isCompleted {
            logger.info(Constants.walletExchangeCompletedMessage)
            completion(.success(result))
        } else {
            logger.error(
                Constants.walletExchangeFailedMessage,
                metadata: [
                    AppLogMetadataKey.error: P2PExchangeError.notEnoughMoney.logDescription
                ]
            )
            completion(.failure(.notEnoughMoney))
        }
    }
    
    func makeAmount(from text: String?) -> Float? {
        let text = text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: Constants.commaSeparator, with: Constants.dotSeparator)
        
        guard let text, !text.isEmpty else { return nil }
        
        return Float(text)
    }
}

// MARK: - Constants
private extension P2PExchangeUseCase {
    enum Constants {
        static let minimumAmount: Float = 0
        static let commaSeparator = ","
        static let dotSeparator = "."
        static let currencyLoadingRequestedMessage = "P2P currency loading was requested from the use case."
        static let offerLoadingRequestedMessage = "P2P offer loading was requested from the use case."
        static let exchangeValidationFailedMessage = "P2P exchange validation failed."
        static let exchangeRepositoryRequestStartedMessage = "P2P exchange repository request was started."
        static let exchangeRepositoryRequestFailedMessage = "P2P exchange repository request failed."
        static let walletExchangeCompletedMessage = "P2P wallet exchange was completed successfully."
        static let walletExchangeFailedMessage = "P2P wallet exchange failed."
    }
}
