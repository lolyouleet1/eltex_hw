import Foundation

struct Candlestick {
    let open: Float
    let close: Float
    let high: Float
    let low: Float
    let recommendation: OperationType
    
    var isGrowing: Bool {
        close >= open
    }
}

enum ChartType: Int {
    case line
    case candlestick
}

struct LineChartPoint {
    let id: UUID
    let value: Float
    let index: Int
    let recommendation: OperationType
}

struct ChartPriceRange {
    let minPrice: Float
    let maxPrice: Float
}
