import Foundation

final class CurrencyRateService {
    // MARK: - Public Methods
    func exchangeRate(from leftCurrency: Currency, to rightCurrency: Currency) -> Float {
        guard rightCurrency.baseValue > .zero else { return .zero }
        
        return AppConfiguration.PriceFormatting.rounded(
            leftCurrency.baseValue / rightCurrency.baseValue
        )
    }
}
