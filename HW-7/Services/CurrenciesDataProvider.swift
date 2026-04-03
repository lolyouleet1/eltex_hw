import UIKit
import Foundation

protocol CurrencyDelegate {
    func currencySelected (_ currency: CurrencyCell)
}

final class CurrenciesDataProvider: NSObject {
    private let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private var currencies = [CurrencyCell]()
    var delegate: CurrencyDelegate?
    var activeSide: SelectedSide = .none
    
    override init() {
        super.init()
        getRandomCurrencies()
    }
}

private extension CurrenciesDataProvider {
    func getRandomCurrencies() {
        for first in alphabet {
            for second in alphabet {
                for third in alphabet {
                    let currency = String(first) + String(second) + String(third)
                    let exchangeRate = (Float.random(in: 0...1000) * 100).rounded() / 100
                    currencies.append(CurrencyCell(label: currency,
                                                   colorIfNotSelected: .green,
                                                   colorIfSelected: .gray,
                                                   selectedSide: .none,
                                                  exchangeRate: exchangeRate))
                }
            }
        }
    }
    
//    func handleCellState(at index: Int, in collectionView: UICollectionView) {
//        currencies[index].isSelected.toggle()
//        
//        let indexPath = IndexPath(item: index, section: 0)
//        collectionView.reloadItems(at: [indexPath])
//    }
}

extension CurrenciesDataProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let currency = currencies[indexPath.item]
        cell.configure(currency)
        
        return cell
    }
}

extension CurrenciesDataProvider: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard activeSide != .none else { return }
        
        let tappedCurrency = currencies[indexPath.item]
        
        if activeSide == .left && tappedCurrency.selectedSide == .right {
            return
        }
        
        if activeSide == .right && tappedCurrency.selectedSide == .left {
            return
        }
        
        if let oldIndex = currencies.firstIndex(where: { $0.selectedSide == activeSide }) {
            currencies[oldIndex].selectedSide = .none
            collectionView.reloadItems(at: [IndexPath(item: oldIndex, section: 0)])
        }
        
        currencies[indexPath.item].selectedSide = activeSide
        collectionView.reloadItems(at: [indexPath])
        
        delegate?.currencySelected(currencies[indexPath.item])
    }
}
