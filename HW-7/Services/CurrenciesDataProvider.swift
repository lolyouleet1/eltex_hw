import UIKit
import Foundation

protocol CurrencyDelegate {
    func currencySelected (_ currency: CurrencyCell)
}

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

final class CurrenciesDataProvider: NSObject {
    private let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private var currencies = [CurrencyCell]()
    private var filteredCurrencies = [CurrencyCell]()
    private var currentFilter: FilterType = .all
    
    var delegate: CurrencyDelegate?
    var activeSide: SelectedSide = .none
    
    override init() {
        super.init()
        getRandomCurrencies()
        applyFilter(.all)
    }
    
    func applyFilter(_ filter: FilterType) {
        currentFilter = filter
        
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
    
    func exchangeRateBetween(_ left: CurrencyCell, _ right: CurrencyCell) -> Float {
        return (left.baseValue / right.baseValue * 100).rounded() / 100
    }
    
    func updateBaseValues(){
        for index in currencies.indices {
            currencies[index].baseValue = (Float.random(in: 0...1000) * 100).rounded() / 100
        }
        
        applyFilter(currentFilter)
    }
    
    func getCurrencyBy(label: String) -> CurrencyCell? {
        return currencies.first { $0.label == label }
    }
}

private extension CurrenciesDataProvider {
    func getRandomCurrencies() {
        var isFiat = true
        for first in alphabet {
            for second in alphabet {
                for third in alphabet {
                    let currency = String(first) + String(second) + String(third)
                    let baseValue = (Float.random(in: 0...1000) * 100).rounded() / 100
                    if isFiat {
                        currencies.append(CurrencyCell(label: currency,
                                                       colorIfNotSelected: .green,
                                                       colorIfSelected: .gray,
                                                       selectedSide: .none,
                                                       baseValue: baseValue,
                                                       type: .fiat))
                    } else {
                        currencies.append(CurrencyCell(label: currency,
                                                       colorIfNotSelected: .green,
                                                       colorIfSelected: .gray,
                                                       selectedSide: .none,
                                                       baseValue: baseValue,
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

        let tappedCurrency = filteredCurrencies[indexPath.item]

        guard let tappedIndexInCurrencies = currencies.firstIndex(where: { $0.label == tappedCurrency.label }) else {
            return
        }

        if activeSide == .left && currencies[tappedIndexInCurrencies].selectedSide == .right {
            return
        }

        if activeSide == .right && currencies[tappedIndexInCurrencies].selectedSide == .left {
            return
        }

        if let oldIndex = currencies.firstIndex(where: { $0.selectedSide == activeSide }) {
            currencies[oldIndex].selectedSide = .none
        }

        currencies[tappedIndexInCurrencies].selectedSide = activeSide

        applyFilter(currentFilter)
        collectionView.reloadData()

        delegate?.currencySelected(currencies[tappedIndexInCurrencies])
    }
}
