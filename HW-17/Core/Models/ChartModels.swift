import Foundation

// MARK: - Models
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

// MARK: - Enums
enum ChartType: Int {
    case line
    case candlestick
}

// MARK: - Models
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
