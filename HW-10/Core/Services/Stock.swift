import Foundation

// MARK: - Protocols
protocol PrintOperation {
    func printOperations(_ amount: OperationsAmount)
}

// MARK: - Stock
final class Stock: PrintOperation {
    
    // MARK: - Properties
    private(set) var balance: Double
    
    private var buyPrices: [Double] = []
    private var tradeResult: Double = 0
    private var totalTradeResult: Double = 0
    private var operations: [Operation] = []
    
    private var stocksAmount: Int {
        buyPrices.count
    }
    
    private var averageBuyPrice: Double? {
        guard !buyPrices.isEmpty else { return nil }
        return buyPrices.reduce(0, +) / Double(buyPrices.count)
    }
    
    // MARK: - Lifecycle
    init(balance: Double) {
        self.balance = balance
    }
    
    // MARK: - Public Methods
    func printOperations(_ amount: OperationsAmount) {
        var snapshot: MarketSnapshot = makeSnapshot()
        
        for _ in 0..<amount.amount {
            snapshot = makeSnapshot()
            let action = makeDecision(snapshot: snapshot)
            let dealInfo = execute(action, snapshot: snapshot)
            
            switch action {
            case .buy:
                print("\(snapshot.currentPrice) рублей - покупка")
                
            case .sell:
                print("\(snapshot.currentPrice) рублей - продажа")
                
                if let startPrice = dealInfo.startPrice,
                   let income = dealInfo.income {
                    print(
                        "Продажа FROM = \(startPrice) -> TO = \(snapshot.currentPrice), INCOME = \(income)"
                    )
                }
                
            case .ignore:
                print("\(snapshot.currentPrice) рублей - игнорирование")
            }
        }
        
        closeRemainingPosition(snapshot: snapshot)
        
        print("---")
        print("Итоговый баланс: \(balance)")
        print("Общий результат сделок: \(totalTradeResult)")
    }
    
    func getOperations(_ amount: Int) -> [Operation] {
        operations.removeAll()
        
        var snapshot: MarketSnapshot = makeSnapshot()
        
        for _ in 0..<amount {
            snapshot = makeSnapshot()
            let action = makeDecision(snapshot: snapshot)
            let dealInfo = execute(action, snapshot: snapshot)
            
            switch action {
            case .buy:
                operations.append(
                    Operation(
                        id: UUID(),
                        text: "\((snapshot.currentPrice * 1000).rounded() / 1000) рублей - покупка",
                        operationType: .buy,
                        price: snapshot.currentPrice
                    )
                )
                
            case .sell:
                if let startPrice = dealInfo.startPrice,
                   let income = dealInfo.income {
                    operations.append(
                        Operation(
                            id: UUID(),
                            text: "Продажа FROM = \((startPrice * 1000).rounded() / 1000) -> TO = \((snapshot.currentPrice * 1000).rounded() / 1000), INCOME = \((income * 1000).rounded() / 1000)",
                            operationType: .sell,
                            price: snapshot.currentPrice
                        )
                    )
                }
                
            case .ignore:
                operations.append(
                    Operation(
                        id: UUID(),
                        text: "\((snapshot.currentPrice * 1000).rounded() / 1000) рублей - игнорирование",
                        operationType: .ignore,
                        price: snapshot.currentPrice
                    )
                )
            }
        }
        
        closeRemainingPosition(snapshot: snapshot)
        
        return operations
    }
    
    func getFinalResult(_ amount: Int) -> (Double, Double) {
        executeWithoutPrinting(amount: amount)
        return (balance, totalTradeResult)
    }
    
    func clearFinalResult(balance: Double) {
        self.balance = balance
        totalTradeResult = 0
        operations = []
    }
}

// MARK: - Private Methods
private extension Stock {
    func makeSnapshot() -> MarketSnapshot {
        MarketSnapshot(
            currentPrice: Double.random(in: Constants.minimumPrice...Constants.maximumPrice),
            buyOrders: Int.random(in: Constants.minimumOrders...Constants.maximumOrders),
            sellOrders: Int.random(in: Constants.minimumOrders...Constants.maximumOrders)
        )
    }
    
    func makeDecision(snapshot: MarketSnapshot) -> Action {
        if snapshot.wantsToSell {
            return !buyPrices.isEmpty && snapshot.spread >= Constants.minimumSpreadForSell
                ? .sell
                : .ignore
        } else {
            return balance > snapshot.currentPrice ? .buy : .ignore
        }
    }
    
    func execute(_ action: Action, snapshot: MarketSnapshot) -> (startPrice: Double?, income: Double?) {
        switch action {
        case .buy:
            buyPrices.append(snapshot.currentPrice)
            balance -= snapshot.currentPrice
            return (nil, nil)
            
        case .sell:
            guard let averageBuyPrice else { return (nil, nil) }
            
            let startPrice = averageBuyPrice
            let amount = Double(stocksAmount)
            
            tradeResult = (snapshot.currentPrice - averageBuyPrice) * amount
            totalTradeResult += tradeResult
            balance += snapshot.currentPrice * Double(stocksAmount)
            buyPrices.removeAll()
            
            return (startPrice, tradeResult)
            
        case .ignore:
            return (nil, nil)
        }
    }
    
    func closeRemainingPosition(snapshot: MarketSnapshot) {
        guard !buyPrices.isEmpty, let averageBuyPrice else { return }
        
        let finalPrice = Double.random(in: Constants.minimumPrice...Constants.maximumPrice)
        let startPrice = averageBuyPrice
        let amount = Double(stocksAmount)
        
        tradeResult = (finalPrice - averageBuyPrice) * amount
        totalTradeResult += tradeResult
        balance += finalPrice * Double(stocksAmount)
        
        operations.append(
            Operation(
                id: UUID(),
                text: "Продажа FROM = \((startPrice * 1000).rounded() / 1000) -> TO = \((finalPrice * 1000).rounded() / 1000)), INCOME = \((tradeResult * 1000).rounded() / 1000)",
                operationType: .sell,
                price: snapshot.currentPrice
            )
        )
        
        buyPrices.removeAll()
    }
    
    func executeWithoutPrinting(amount: Int) {
        var snapshot: MarketSnapshot = makeSnapshot()
        
        for _ in 0..<amount {
            snapshot = makeSnapshot()
            let action = makeDecision(snapshot: snapshot)
            _ = execute(action, snapshot: snapshot)
        }
        
        closeRemainingPosition(snapshot: snapshot)
    }
}

// MARK: - Constants
private extension Stock {
    enum Constants {
        static let minimumPrice: Double = 100
        static let maximumPrice: Double = 200
        static let minimumOrders: Int = 0
        static let maximumOrders: Int = 10_000
        static let minimumSpreadForSell: Int = 400
    }
}
