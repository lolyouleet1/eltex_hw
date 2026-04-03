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
    var filteredCurrencies = [CurrencyCell]()
    
    override init() {
        super.init()
        getRandomCurrencies()
        applyFilter(.all)
    }
    
    func applyFilter(_ filter: FilterType) {
        switch filter {
        case .all:
            filteredCurrencies = currencies
        case .fiat:
            filteredCurrencies = currencies.filter {
                $0.type == .fiat
            }
        case .crypto:
            filteredCurrencies = currencies.filter {
                $0.type == .crypto
            }
        }
    }
}

private extension CurrenciesDataProvider {
    func getRandomCurrencies() {
        var isFiat = true
        for first in alphabet {
            for second in alphabet {
                for third in alphabet {
                    let currency = String(first) + String(second) + String(third)
                    let exchangeRate = (Float.random(in: 0...1000) * 100).rounded() / 100
                    if isFiat {
                        currencies.append(CurrencyCell(label: currency,
                                                       colorIfNotSelected: .green,
                                                       colorIfSelected: .gray,
                                                       selectedSide: .none,
                                                      exchangeRate: exchangeRate,
                                                       type: .fiat))
                    } else {
                        currencies.append(CurrencyCell(label: currency,
                                                       colorIfNotSelected: .green,
                                                       colorIfSelected: .gray,
                                                       selectedSide: .none,
                                                      exchangeRate: exchangeRate,
                                                       type: .crypto))
                    }
                    isFiat.toggle()
                }
            }
        }
    }
}

extension CurrenciesDataProvider: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCurrencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let currency = filteredCurrencies[indexPath.item]
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
