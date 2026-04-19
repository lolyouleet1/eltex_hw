import Foundation

final class TradingRunService {
    // MARK: - Dependencies
    private let tradingEngine: TradingEngine
    
    // MARK: - Lifecycle
    init(tradingEngine: TradingEngine) {
        self.tradingEngine = tradingEngine
    }
    
    // MARK: - Public Methods
    func makeResult(startBalance: Float, cycles: Int) -> TradingRunResult {
        let engineResult = tradingEngine.makeResult(startBalance: startBalance, cycles: cycles)
        let candlesticks = CandlestickFactory.makeCandlesticks(from: engineResult.operations)
        let lineChartPoints = LinesFactory.makeLinePoints(from: engineResult.operations)
        
        return TradingRunResult(
            cycles: cycles,
            finalBalance: engineResult.finalBalance,
            finalProfit: engineResult.finalProfit,
            operations: engineResult.operations,
            candlesticks: candlesticks,
            lineChartPoints: lineChartPoints
        )
    }
}
