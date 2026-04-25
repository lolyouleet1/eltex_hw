import Foundation
import CoreGraphics

// MARK: - Enums
enum CurrencyItemSelectionState {
    case none
    case left
    case right
}

// MARK: - Models
struct CurrencyItemViewModel {
    let id: UUID
    let title: String
    let isFavorite: Bool
    let selectionState: CurrencyItemSelectionState
}

struct BotResultCellViewModel {
    let text: String
    let tone: ResultTone
}

struct GraphCandlestickItemViewModel {
    let candlestick: Candlestick
    let bodyHeight: CGFloat
    let tailHeight: CGFloat
    let verticalOffset: CGFloat
    
    var isGrowing: Bool {
        candlestick.isGrowing
    }
}

struct LineChartPointViewModel {
    let point: LineChartPoint
    let size: CGFloat
}

// MARK: - Enums
enum ResultTone {
    case neutral
    case positive
    case negative
}

enum RecommendationTone {
    case neutral
    case buy
    case sell
    case ignore
}
