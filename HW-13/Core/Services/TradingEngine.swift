import Foundation

struct TradingEngineResult {
    let finalBalance: Float
    let finalProfit: Float
    let operations: [Operation]
}

final class TradingEngine {
    // MARK: - Dependencies
    private let marketDataGenerator: MarketDataGenerator
    
    // MARK: - Lifecycle
    init(marketDataGenerator: MarketDataGenerator) {
        self.marketDataGenerator = marketDataGenerator
    }
    
    // MARK: - Public Methods
    func makeResult(startBalance: Float, cycles: Int) -> TradingEngineResult {
        var balance = startBalance
        var buyPrices: [Float] = []
        var totalTradeResult: Float = .zero
        var operations: [Operation] = []
        
        for _ in 0..<cycles {
            let snapshot = marketDataGenerator.makeSnapshot()
            let action = makeAction(snapshot: snapshot, balance: balance, buyPrices: buyPrices)
            let executionResult = execute(
                action,
                snapshot: snapshot,
                balance: &balance,
                buyPrices: &buyPrices,
                totalTradeResult: &totalTradeResult
            )
            
            operations.append(
                Operation(
                    id: UUID(),
                    operationType: action.operationType,
                    snapshot: snapshot,
                    startPrice: executionResult.startPrice,
                    income: executionResult.income
                )
            )
        }
        
        if let closingOperation = makeClosingOperation(
            balance: &balance,
            buyPrices: &buyPrices,
            totalTradeResult: &totalTradeResult
        ) {
            operations.append(closingOperation)
        }
        
        return TradingEngineResult(
            finalBalance: balance,
            finalProfit: totalTradeResult,
            operations: operations
        )
    }
    
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
    func makeAction(snapshot: MarketSnapshot, balance: Float, buyPrices: [Float]) -> TradingAction {
        if snapshot.wantsToSell {
            return !buyPrices.isEmpty && snapshot.spread >= Constants.minimumSpreadForSell
                ? .sell
                : .ignore
        }
        
        return balance > snapshot.currentPrice ? .buy : .ignore
    }
    
    func execute(_ action: TradingAction, snapshot: MarketSnapshot, balance: inout Float, buyPrices: inout [Float], totalTradeResult: inout Float) -> TradingExecutionResult {
        switch action {
        case .buy:
            buyPrices.append(snapshot.currentPrice)
            balance -= snapshot.currentPrice
            
            return TradingExecutionResult(startPrice: nil, income: nil)
        case .sell:
            guard let averageBuyPrice = buyPrices.average else {
                return TradingExecutionResult(startPrice: nil, income: nil)
            }
            
            let amount = Float(buyPrices.count)
            let tradeResult = (snapshot.currentPrice - averageBuyPrice) * amount
            
            totalTradeResult += tradeResult
            balance += snapshot.currentPrice * amount
            buyPrices.removeAll()
            
            return TradingExecutionResult(
                startPrice: averageBuyPrice,
                income: tradeResult
            )
        case .ignore:
            return TradingExecutionResult(startPrice: nil, income: nil)
        }
    }
    
    func makeClosingOperation(balance: inout Float, buyPrices: inout [Float], totalTradeResult: inout Float) -> Operation? {
        guard !buyPrices.isEmpty else { return nil }
        
        let closingSnapshot = marketDataGenerator.makeSnapshot()
        let executionResult = execute(
            .sell,
            snapshot: closingSnapshot,
            balance: &balance,
            buyPrices: &buyPrices,
            totalTradeResult: &totalTradeResult
        )
        
        return Operation(
            id: UUID(),
            operationType: .sell,
            snapshot: closingSnapshot,
            startPrice: executionResult.startPrice,
            income: executionResult.income
        )
    }
    
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

// MARK: - Models
private extension TradingEngine {
    enum TradingAction {
        case buy
        case sell
        case ignore
        
        var operationType: OperationType {
            switch self {
            case .buy:
                return .buy
            case .sell:
                return .sell
            case .ignore:
                return .ignore
            }
        }
    }
    
    struct TradingExecutionResult {
        let startPrice: Float?
        let income: Float?
    }
}

private extension Array where Element == Float {
    var average: Float? {
        guard !isEmpty else { return nil }
        
        return reduce(.zero, +) / Float(count)
    }
}
