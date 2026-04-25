import Foundation

// MARK: - Enums
enum SelectedSide {
    case left
    case right
}

// MARK: - Models
struct Currency: Identifiable {
    let id: UUID
    let code: String
    var baseValue: Float
    let type: CurrencyType
    var isFavorite: Bool
}

// MARK: - Enums
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
