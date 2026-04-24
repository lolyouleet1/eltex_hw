import Foundation

final class TradingRunService {
    // MARK: - Dependencies
    private let tradingEngine: TradingEngine
    private let wallet: Wallet
    
    // MARK: - Lifecycle
    init(tradingEngine: TradingEngine, wallet: Wallet) {
        self.tradingEngine = tradingEngine
        self.wallet = wallet
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
    
    func runBots(bots: [WalletBot]) -> [BotDayResult] {
        let workQueue = DispatchQueue.global(qos: .userInitiated)
        let resultQueue = DispatchQueue(label: "result.queue")
        let group = DispatchGroup()
        
        let daysAmount = AppConfiguration.TradeBotSettings.workingDays
        var result: [BotDayResult] = Array(repeating: makeEmptyBotDayResult(), count: (daysAmount + 1) * bots.count)
        
        for dayNumber in 0..<daysAmount {
            for botIndex in bots.indices {
                let baseCurrencyCode = bots[botIndex].pair.base.code
                let quoteCurrencyCode = bots[botIndex].pair.quote.code
                let pairName = "\(baseCurrencyCode)-\(quoteCurrencyCode)"
                
                group.enter()
                workQueue.async {
                    let totalIncome = self.tradingEngine.makeResultBot(wallet: self.wallet, bot: bots[botIndex])
                    
                    resultQueue.sync {
                        let index = dayNumber * bots.count + botIndex
                        
                        result[index] = BotDayResult(
                            botName: bots[botIndex].name,
                            currencyPair: pairName,
                            day: dayNumber,
                            income: totalIncome,
                            incomeCurrencyCode: quoteCurrencyCode
                        )
                        
                        group.leave()
                    }
                }
            }
        }
        
        group.wait()
        return result
    }
}

// MARK: - Private Methods
private extension TradingRunService {
    func makeEmptyBotDayResult() -> BotDayResult {
        return BotDayResult(
            botName: "0",
            currencyPair: "0",
            day: .zero,
            income: .zero,
            incomeCurrencyCode: "0"
        )
    }
}
