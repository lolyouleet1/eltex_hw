import UIKit

// MARK: - Protocols
protocol CurrencyDelegate: AnyObject {
    func currencySelected(_ currency: CurrencyCell)
}

// MARK: - Data Provider
final class CurrenciesDataProvider: NSObject {
    
    // MARK: - Properties
    private var currencies: [CurrencyCell] = []
    private var filteredCurrencies: [CurrencyCell] = []
    private var currentFilter: FilterType = .all
    
    weak var delegate: CurrencyDelegate?
    weak var cellDelegate: CollectionViewCellDelegate?
    var activeSide: SelectedSide = .none
    
    var isFilteredCurrenciesEmpty: Bool {
        filteredCurrencies.isEmpty
    }
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        generateCurrencies()
        applyFilters(typeFilter: .all, favoritesOnly: false)
    }
    
    // MARK: - Public Methods
    func applyFilters(typeFilter: FilterType, favoritesOnly: Bool) {
        
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
        
        filteredCurrencies = result
    }
    
    func applyFiltersCompact(typeFilter: CompactFilterType) {
        var result = currencies
        
        switch typeFilter {
        case .favorite:
            result = result.filter { $0.isFavorite == true }
        case .all:
            break
        }
        
        filteredCurrencies = result
    }
    
    func exchangeRateBetween(_ left: CurrencyCell, _ right: CurrencyCell) -> Float {
        (left.baseValue / right.baseValue * Constants.roundingMultiplier).rounded() / Constants.roundingMultiplier
    }
    
    func updateBaseValues() {
        for index in currencies.indices {
            currencies[index].baseValue = makeRandomBaseValue()
        }
    }
    
    func currency(withLabel label: String) -> CurrencyCell? {
        currencies.first { $0.label == label }
    }
    
    func toggleFavorite(at index: Int) {
        let tappedCurrency = filteredCurrencies[index]
        
        guard let realIndex = currencies.firstIndex(where: { $0.label == tappedCurrency.label }) else {
            return
        }
        
        currencies[realIndex].isFavorite.toggle()
    }
}

// MARK: - Private Methods
private extension CurrenciesDataProvider {
    func generateCurrencies() {
        var isFiat = true
        
        for first in Constants.alphabet {
            for second in Constants.alphabet {
                for third in Constants.alphabet {
                    let code = String(first) + String(second) + String(third)
                    let type: CurrencyType = isFiat ? .fiat : .crypto
                    
                    currencies.append(
                        makeCurrencyCell(
                            label: code,
                            baseValue: makeRandomBaseValue(),
                            type: type
                        )
                    )
                    
                    isFiat.toggle()
                }
            }
        }
    }
    
    func makeCurrencyCell(label: String, baseValue: Float, type: CurrencyType) -> CurrencyCell {
        CurrencyCell(
            label: label,
            colorIfNotSelected: .green,
            colorIfSelected: .gray,
            selectedSide: .none,
            baseValue: baseValue,
            type: type,
            isFavorite: false
        )
    }
    
    func makeRandomBaseValue() -> Float {
        (Float.random(in: Constants.minimumBaseValue...Constants.maximumBaseValue) * Constants.roundingMultiplier).rounded() / Constants.roundingMultiplier
    }
    
    func canSelectCurrency(at index: Int) -> Bool {
        if activeSide == .left && currencies[index].selectedSide == .right {
            return false
        }
        
        if activeSide == .right && currencies[index].selectedSide == .left {
            return false
        }
        
        return true
    }
    
    func clearPreviousSelectionIfNeeded() {
        if let oldIndex = currencies.firstIndex(where: { $0.selectedSide == activeSide }) {
            currencies[oldIndex].selectedSide = .none
        }
    }
}

extension CurrenciesDataProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredCurrencies.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.identifier,
            for: indexPath
        ) as? CollectionViewCell else {
            fatalError("Could not dequeue CollectionViewCell")
        }
        
        let currency = filteredCurrencies[indexPath.item]
        cell.configure(with: currency)
        cell.delegate = cellDelegate
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CurrenciesDataProvider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard activeSide != .none else { return }
        
        let tappedCurrency = filteredCurrencies[indexPath.item]
        
        guard let selectedIndex = currencies.firstIndex(where: { $0.label == tappedCurrency.label }) else {
            return
        }
        
        guard canSelectCurrency(at: selectedIndex) else { return }
        
        clearPreviousSelectionIfNeeded()
        currencies[selectedIndex].selectedSide = activeSide
        
        applyFilters(typeFilter: currentFilter, favoritesOnly: false)
        collectionView.reloadData()
        
        delegate?.currencySelected(currencies[selectedIndex])
    }
}

// MARK: - Constants
private extension CurrenciesDataProvider {
    enum Constants {
        static let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        static let minimumBaseValue: Float = 0
        static let maximumBaseValue: Float = 1000
        static let roundingMultiplier: Float = 100
    }
}
