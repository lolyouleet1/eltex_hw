import Foundation

final class TradingSession {
    let stock: Stock

    var cycles: Int = 0
    var operations: [Operation] = []
    var candlesticks: [Candlestick] = []
    var finalBalance: Double
    var finalProfit: Double = 0

    init(startBalance: Double) {
        self.stock = Stock(balance: startBalance)
        self.finalBalance = startBalance
    }
}
