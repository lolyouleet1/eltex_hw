import Foundation

protocol CurrencyRepositoryProtocol: AnyObject {
    func getCurrencies() -> [Currency]
    func getCurrency(id: UUID) -> Currency?
    func toggleFavorite(currencyID: UUID)
    func updateBaseValues()
}

final class MockCurrencyRepository: CurrencyRepositoryProtocol {
    // MARK: - Properties
    private var currencies: [Currency]
    
    // MARK: - Lifecycle
    init() {
        currencies = Self.makeCurrencies()
    }
    
    // MARK: - Public Methods
    func getCurrencies() -> [Currency] {
        currencies
    }
    
    func getCurrency(id: UUID) -> Currency? {
        currencies.first { $0.id == id }
    }
    
    func toggleFavorite(currencyID: UUID) {
        guard let index = currencies.firstIndex(where: { $0.id == currencyID }) else { return }
        
        currencies[index].isFavorite.toggle()
    }
    
    func updateBaseValues() {
        for index in currencies.indices {
            currencies[index].baseValue = Self.makeRandomBaseValue()
        }
    }
}

// MARK: - Private Methods
private extension MockCurrencyRepository {
    static func makeCurrencies() -> [Currency] {
        var result: [Currency] = []
        var isFiat = true
        
        for firstCharacter in Constants.alphabet {
            for secondCharacter in Constants.alphabet {
                for thirdCharacter in Constants.alphabet {
                    let code = String(firstCharacter) + String(secondCharacter) + String(thirdCharacter)
                    let type: CurrencyType = isFiat ? .fiat : .crypto
                    
                    result.append(
                        Currency(
                            id: UUID(),
                            code: code,
                            baseValue: makeRandomBaseValue(),
                            type: type,
                            isFavorite: false
                        )
                    )
                    
                    isFiat.toggle()
                }
            }
        }
        
        return result
    }
    
    static func makeRandomBaseValue() -> Float {
        AppConfiguration.PriceFormatting.rounded(
            Float.random(in: AppConfiguration.TradeBotSettings.minCurrencyBaseValue...AppConfiguration.TradeBotSettings.maxCurrencyBaseValue)
        )
    }
}

// MARK: - Constants
private extension MockCurrencyRepository {
    enum Constants {
        static let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    }
}
