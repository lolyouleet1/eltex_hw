import UIKit

enum SelectedSide {
    case none
    case left
    case right
}

struct CurrencyCell {
    let label: String
    let colorIfNotSelected: UIColor
    let colorIfSelected: UIColor
    var selectedSide: SelectedSide
    var baseValue: Float
    let type: CurrencyType
    var isFavorite: Bool
}

enum CurrencyType {
    case fiat
    case crypto
}

enum FilterType {
    case all
    case fiat
    case crypto
}

enum CompactFilterType {
    case all
    case favorite
}
