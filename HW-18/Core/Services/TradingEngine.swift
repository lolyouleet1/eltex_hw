import Foundation

final class TradingEngine {
    // MARK: - Dependencies
    private let marketDataGenerator: MarketDataGenerator
    
    // MARK: - Lifecycle
    init(marketDataGenerator: MarketDataGenerator) {
        self.marketDataGenerator = marketDataGenerator
    }
    
    // MARK: - Public Methods
    func makeResultBot(wallet: Wallet, bot: WalletBot) -> Float {
        var buyPrices: [Float] = []
        var totalIncome: Float = .zero
        
        let operationsAmount: Int = Int.random(in: AppConfiguration.TradeBotSettings.minOperationsPerDay...AppConfiguration.TradeBotSettings.maxOperationsPerDay)
        
        for _ in 0..<operationsAmount {
            let snapshot = marketDataGenerator.makeSnapshot()
            let action = makeOperationDecision(snapshot: snapshot)
            let baseCurrency = bot.pair.base
            let quoteCurrency = bot.pair.quote
            let buyAmount: Int = Int.random(in: AppConfiguration.TradeBotSettings.minBuyAmount...AppConfiguration.TradeBotSettings.maxBuyAmount)
            
            switch action {
            case .buy:
                for _ in 0..<buyAmount {
                    buyPrices.append(snapshot.currentPrice)
                }
                wallet.buy(base: baseCurrency, quote: quoteCurrency, price: snapshot.currentPrice, amount: buyAmount)
            case .sell:
                guard let averageBuyPrice = buyPrices.average else { continue }
                
                let amount = buyPrices.count
                let differenceInPrices = snapshot.currentPrice - averageBuyPrice
                let tradeResult = differenceInPrices * Float(amount)
                
                wallet.sell(base: baseCurrency, quote: quoteCurrency, price: snapshot.currentPrice, amount: amount)
                totalIncome += tradeResult
                
                buyPrices.removeAll()
            case .ignore:
               continue
            }
        }
        
        return totalIncome
    }
}

// MARK: - Private Methods
private extension TradingEngine {
    func makeOperationDecision(snapshot: MarketSnapshot) -> OperationType {
        if snapshot.wantsToSell {
            return snapshot.spread >= Constants.minimumSpreadForSell
                ? .sell
                : .ignore
        }
        
        return .buy
    }
}

// MARK: - Constants
private extension TradingEngine {
    enum Constants {
        static let minimumSpreadForSell: Int = 400
    }
}

private extension Array where Element == Float {
    var average: Float? {
        guard !isEmpty else { return nil }
        
        return reduce(.zero, +) / Float(count)
    }
}
