import Foundation

// MARK: - Models
struct MarketSnapshot {
    let currentPrice: Float
    let buyOrders: Int
    let sellOrders: Int

    var spread: Int {
        sellOrders - buyOrders
    }

    var wantsToSell: Bool {
        sellOrders > buyOrders
    }
}

// MARK: - Enums
enum OperationType {
    case buy
    case sell
    case ignore
}

// MARK: - Models
struct Operation {
    let id: UUID
    let operationType: OperationType
    let snapshot: MarketSnapshot
    let startPrice: Float?
    let income: Float?
    
    var price: Float {
        snapshot.currentPrice
    }
}

struct TradingRunResult {
    let cycles: Int
    let finalBalance: Float
    let finalProfit: Float
    let operations: [Operation]
    let candlesticks: [Candlestick]
    let lineChartPoints: [LineChartPoint]
}
