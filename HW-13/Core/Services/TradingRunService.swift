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
        // ДОБАВИТЬ ЕЩЕ ОДНУ ОЧЕРЕДЬ ДЛЯ ДОБАВЛЕНИЯ РЕЗУЛЬТАТА
        let group = DispatchGroup()
        
        var result: [BotDayResult] = []
        
        let daysAmount = AppConfiguration.TradeBotSettings.workingDays
        
        for dayNumber in 0..<daysAmount {
            for bot in bots {
                let baseCurrencyCode = bot.pair.base.code
                let quoteCurrencyCode = bot.pair.quote.code
                let pairName = "\(baseCurrencyCode)-\(quoteCurrencyCode)"
                
                group.enter()
                
                workQueue.async {
                    let totalIncome = self.tradingEngine.makeResultBot(wallet: self.wallet, bot: bot)
                    
                    result.append(BotDayResult(
                        botName: bot.name,
                        currencyPair: pairName,
                        day: dayNumber,
                        income: totalIncome,
                        incomeCurrencyCode: quoteCurrencyCode
                    ))
                }
            }
        }
        
        group.wait()
        return result
    }
}
