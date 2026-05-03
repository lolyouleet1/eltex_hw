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

struct P2POfferCellViewModel {
    let sellerText: String
    let rateText: String
    let reserveText: String
}

struct P2PAlertViewModel {
    let title: String
    let message: String
}

struct P2PExchangeInputViewModel {
    let title: String
    let message: String
    let placeholder: String
    let actionTitle: String
    let cancelTitle: String
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
