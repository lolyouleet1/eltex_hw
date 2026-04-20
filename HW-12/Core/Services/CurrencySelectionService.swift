import Foundation

final class CurrencySelectionService {
    // MARK: - Properties
    private(set) var leftCurrencyID: UUID?
    private(set) var rightCurrencyID: UUID?
    
    // MARK: - Public Methods
    func selectedCurrencyID(for side: SelectedSide) -> UUID? {
        switch side {
        case .left:
            return leftCurrencyID
        case .right:
            return rightCurrencyID
        }
    }
    
    func selectionState(for currencyID: UUID) -> CurrencyItemSelectionState {
        if leftCurrencyID == currencyID {
            return .left
        }
        
        if rightCurrencyID == currencyID {
            return .right
        }
        
        return .none
    }
    
    @discardableResult
    func select(currencyID: UUID, for side: SelectedSide) -> Bool {
        switch side {
        case .left:
            guard rightCurrencyID != currencyID else { return false }
            leftCurrencyID = currencyID
        case .right:
            guard leftCurrencyID != currencyID else { return false }
            rightCurrencyID = currencyID
        }
        
        return true
    }

    func selectRandomPair(from currencies: [Currency]) -> (left: UUID, right: UUID)? {
        guard let leftCurrency = currencies.randomElement() else { return nil }
        
        let remainingCurrencies = currencies.filter { $0.id != leftCurrency.id }
        guard let rightCurrency = remainingCurrencies.randomElement() else { return nil }
        
        leftCurrencyID = leftCurrency.id
        rightCurrencyID = rightCurrency.id
        
        return (leftCurrency.id, rightCurrency.id)
    }
}
