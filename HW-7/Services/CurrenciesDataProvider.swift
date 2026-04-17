import UIKit

// MARK: - Protocols
protocol CurrencyDelegate: AnyObject {
    func currencySelected(_ currency: CurrencyCell)
}

// MARK: - Models
struct CurrencyCell {
    let label: String
    let colorIfNotSelected: UIColor
    let colorIfSelected: UIColor
    var selectedSide: SelectedSide
    var baseValue: Float
    let type: CurrencyType
}

enum CurrencyType {
    case fiat
    case crypto
}

// MARK: - Data Provider
final class CurrenciesDataProvider: NSObject {
    
    // MARK: - Constants
    private enum Constants {
        static let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        static let minimumBaseValue: Float = 0
        static let maximumBaseValue: Float = 1000
        static let roundingMultiplier: Float = 100
    }
    
    // MARK: - Properties
    private var currencies: [CurrencyCell] = []
    private var filteredCurrencies: [CurrencyCell] = []
    private var currentFilter: FilterType = .all
    
    weak var delegate: CurrencyDelegate?
    var activeSide: SelectedSide = .none
    
    // MARK: - Lifecycle
    override init() {
        super.init()
        generateCurrencies()
        applyFilter(.all)
    }
    
    // MARK: - Public Methods
    func applyFilter(_ filter: FilterType) {
        currentFilter = filter
        
        switch filter {
        case .all:
            filteredCurrencies = currencies
        case .fiat:
            filteredCurrencies = currencies.filter { $0.type == .fiat }
        case .crypto:
            filteredCurrencies = currencies.filter { $0.type == .crypto }
        }
    }
    
    func exchangeRateBetween(_ left: CurrencyCell, _ right: CurrencyCell) -> Float {
        (left.baseValue / right.baseValue * Constants.roundingMultiplier).rounded() / Constants.roundingMultiplier
    }
    
    func updateBaseValues() {
        for index in currencies.indices {
            currencies[index].baseValue = makeRandomBaseValue()
        }
        
        applyFilter(currentFilter)
    }
    
    func currency(withLabel label: String) -> CurrencyCell? {
        currencies.first { $0.label == label }
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
            type: type
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

// MARK: - UICollectionViewDataSource
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
        
        applyFilter(currentFilter)
        collectionView.reloadData()
        
        delegate?.currencySelected(currencies[selectedIndex])
    }
}
