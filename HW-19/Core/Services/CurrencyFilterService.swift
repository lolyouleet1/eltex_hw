import Foundation

final class CurrencyFilterService {
    // MARK: - Public Methods
    func makeCurrencies(from currencies: [Currency], typeFilter: FilterType, favoritesOnly: Bool) -> [Currency] {
        var result = currencies
        
        switch typeFilter {
        case .all:
            break
        case .fiat:
            result = result.filter { $0.type == .fiat }
        case .crypto:
            result = result.filter { $0.type == .crypto }
        }
        
        if favoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        
        return result
    }
    
    func makeCurrencies(from currencies: [Currency], compactFilter: CompactFilterType) -> [Currency] {
        switch compactFilter {
        case .all:
            return currencies
        case .favorite:
            return currencies.filter { $0.isFavorite }
        }
    }
}
