import Foundation

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

enum OperationType {
    case buy
    case sell
    case ignore
}

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
