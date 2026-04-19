import Foundation

enum SelectedSide {
    case left
    case right
}

struct Currency: Identifiable {
    let id: UUID
    let code: String
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
