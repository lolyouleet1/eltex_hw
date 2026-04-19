import Foundation
import CoreGraphics

enum CurrencyItemSelectionState {
    case none
    case left
    case right
}

struct CurrencyItemViewModel {
    let id: UUID
    let title: String
    let isFavorite: Bool
    let selectionState: CurrencyItemSelectionState
}

struct OperationCellViewModel {
    let text: String
    let operationType: OperationType
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
