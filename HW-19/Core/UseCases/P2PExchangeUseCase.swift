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
    
    // MARK: - Lifecycle
    init(repository: P2PRepositoryProtocol, wallet: Wallet) {
        self.repository = repository
        self.wallet = wallet
    }
    
    // MARK: - Public Methods
    func loadCurrencies(completion: @escaping (Result<[Currency], NetworkError>) -> Void) {
        repository.getCurrencies(completion: completion)
    }
    
    func loadOffers(sendCurrency: Currency, receiveCurrency: Currency, completion: @escaping (Result<[P2POffer], NetworkError>) -> Void) {
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
            completion(.failure(.invalidAmount))
            return
        }
        
        guard wallet.balance(for: sendCurrency.code) >= sendAmount else {
            completion(.failure(.notEnoughMoney))
            return
        }
        
        let receiveAmount = AppConfiguration.PriceFormatting.rounded(sendAmount * offer.rate)
        guard receiveAmount <= offer.reserve else {
            completion(.failure(.reserveIsTooLow))
            return
        }
        
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
            completion(.success(result))
        } else {
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
    }
}
