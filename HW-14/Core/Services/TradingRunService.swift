import Foundation

final class TradingRunService {
    // MARK: - Dependencies
    private let tradingEngine: TradingEngine
    private let wallet: Wallet
    
    // MARK: - State
    private var completedDays: Int = .zero
    
    // MARK: - Lifecycle
    init(tradingEngine: TradingEngine, wallet: Wallet) {
        self.tradingEngine = tradingEngine
        self.wallet = wallet
    }
    
    // MARK: - Public Methods
    func runBots(bots: [WalletBot]) -> [BotDayResult] {
        let workQueue = DispatchQueue.global(qos: .userInitiated)
        let resultQueue = DispatchQueue(label: Constants.resultQueueLabel)
        let group = DispatchGroup()
        
        let daysAmount = AppConfiguration.TradeBotSettings.workingDays
        let firstDay = completedDays + Constants.firstDayOffset
        var result: [BotDayResult] = Array(
            repeating: makeEmptyBotDayResult(),
            count: daysAmount * bots.count
        )
        
        for dayIndex in 0..<daysAmount {
            for botIndex in bots.indices {
                let baseCurrencyCode = bots[botIndex].pair.base.code
                let quoteCurrencyCode = bots[botIndex].pair.quote.code
                let pairName = "\(baseCurrencyCode)\(Constants.currencyPairSeparator)\(quoteCurrencyCode)"
                
                group.enter()
                workQueue.async {
                    defer {
                        group.leave()
                    }
                    
                    let totalIncome = self.tradingEngine.makeResultBot(wallet: self.wallet, bot: bots[botIndex])
                    
                    resultQueue.sync {
                        let index = dayIndex * bots.count + botIndex
                        
                        result[index] = BotDayResult(
                            botName: bots[botIndex].name,
                            currencyPair: pairName,
                            day: firstDay + dayIndex,
                            income: totalIncome,
                            incomeCurrencyCode: quoteCurrencyCode
                        )
                    }
                }
            }
            
            group.wait()
        }
        
        completedDays += daysAmount
        
        return result
    }
    
    func walletSnapshot() -> WalletSnapshot {
        wallet.walletSnapshot()
    }
}

// MARK: - Private Methods
private extension TradingRunService {
    func makeEmptyBotDayResult() -> BotDayResult {
        return BotDayResult(
            botName: Constants.emptyValue,
            currencyPair: Constants.emptyValue,
            day: .zero,
            income: .zero,
            incomeCurrencyCode: Constants.emptyValue
        )
    }
}

// MARK: - Constants
private extension TradingRunService {
    enum Constants {
        static let resultQueueLabel = "result.queue"
        static let currencyPairSeparator = "-"
        static let emptyValue = "0"
        static let firstDayOffset = 1
    }
}
