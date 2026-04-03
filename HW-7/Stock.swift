import Foundation

enum OperationsAmount {
    case small
    case medium
    case large
    
    var amount: Int {
        switch self {
        case .small:
            return Int.random(in: 1..<20)
            
        case .medium:
            return Int.random(in: 20..<40)
            
        case .large:
            return Int.random(in: 40..<80)
        }
    }
}

enum Action {
    case buy
    case sell
    case ignore
}

struct MarketSnapshot {
    let currentPrice: Double
    let buyOrders: Int
    let sellOrders: Int

    var spread: Int {
        sellOrders - buyOrders
    }

    var wantsToSell: Bool {
        sellOrders > buyOrders
    }
}

protocol PrintOperation {
    func printOperations(_ amount: OperationsAmount)
}

final class Stock: PrintOperation {
    private(set) var balance: Double
    private var buyPrices = [Double]()
    private var tradeResult: Double = 0
    private var totalTradeResult: Double = 0
    private var operations: [Operation] = []
    
    init(balance: Double) {
        self.balance = balance
    }
    
    private var stocksAmount: Int {
        buyPrices.count
    }
    
    private var averageBuyPrice: Double? {
        guard !buyPrices.isEmpty else { return nil }
        return buyPrices.reduce(0, +) / Double(buyPrices.count)
    }
    
    func printOperations(_ amount: OperationsAmount) {
        for _ in 0..<amount.amount {
            let snapshot = makeSnapshot()
            let action = makeDecision(snapshot: snapshot)
            let dealInfo = execute(action, snapshot: snapshot)

            switch action {
            case .buy:
                print("\(snapshot.currentPrice) рублей - покупка")
                
            case .sell:
                print("\(snapshot.currentPrice) рублей - продажа")
                if let startPrice = dealInfo.startPrice, let income = dealInfo.income {
                    print("Продажа FROM = \(startPrice) -> TO = \(snapshot.currentPrice), INCOME = \(income)")
                }
    
            case .ignore:
                print("\(snapshot.currentPrice) рублей - игнорирование")
            }
        }
        closeRemainingPosition()
        print("---")
        print("Итоговый баланс: \(balance)")
        print("Общий результат сделок: \(totalTradeResult)")
    }
    
    func getOperations(_ amount: Int) -> [Operation] {
        operations.removeAll()
        for _ in 0..<amount {
            let snapshot = makeSnapshot()
            let action = makeDecision(snapshot: snapshot)
            let dealInfo = execute(action, snapshot: snapshot)

            switch action {
            case .buy:
                operations.append(Operation(id: UUID(),
                                            text: "\((snapshot.currentPrice * 1000).rounded() / 1000) рублей - покупка",
                                            operationType: .buy))
            case .sell:
                if let startPrice = dealInfo.startPrice, let income = dealInfo.income {
                    operations.append(Operation(id: UUID(),
                                                text: "Продажа FROM = \((startPrice * 1000).rounded() / 1000) -> TO = \((snapshot.currentPrice * 1000).rounded() / 1000), INCOME = \((income * 1000).rounded() / 1000)",
                                                operationType: .sell))
                }
            case .ignore:
                operations.append(Operation(id: UUID(),
                                            text: "\((snapshot.currentPrice * 1000).rounded() / 1000) рублей - игнорирование",
                                            operationType: .ignore))
            }
        }
        closeRemainingPosition()
        
        return operations
    }
    
    func getFinalResult(_ amount: Int) -> (Double, Double) {
        executeWithoutPrinting(amount)
        return (balance, totalTradeResult)
    }
}

private extension Stock {
    func makeSnapshot() -> MarketSnapshot {
        MarketSnapshot(
            currentPrice: Double.random(in: 100...200),
            buyOrders: Int.random(in: 0...10000),
            sellOrders: Int.random(in: 0...10000)
        )
    }
    
    func makeDecision(snapshot: MarketSnapshot) -> Action {
        if snapshot.wantsToSell {
            return !buyPrices.isEmpty && snapshot.spread >= 400 ? .sell : .ignore
        } else {
            return balance > snapshot.currentPrice ? .buy : .ignore
        }
    }
    
    // calculations for every operation
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
    
    func closeRemainingPosition() {
        guard !buyPrices.isEmpty, let averageBuyPrice else {
            return
        }

        let finalPrice = Double.random(in: 100...200)
        let startPrice = averageBuyPrice
        let amount = Double(stocksAmount)
        tradeResult = (finalPrice - averageBuyPrice) * amount
        totalTradeResult += tradeResult
        balance += finalPrice * Double(stocksAmount)

        operations.append(Operation(id: UUID(),
                                    text: "Продажа FROM = \((startPrice * 1000).rounded() / 1000) -> TO = \((finalPrice * 1000).rounded() / 1000)), INCOME = \((tradeResult * 1000).rounded() / 1000)",
                                    operationType: .sell))
//        print("\(finalPrice) рублей - продажа")
//        print("Продажа FROM = \(startPrice) -> TO = \(finalPrice), INCOME = \(tradeResult)")

        buyPrices.removeAll()
    }
    
    func executeWithoutPrinting(_ amount: Int) {
        for _ in 0..<amount {
            let snapshot = makeSnapshot()
            let action = makeDecision(snapshot: snapshot)
            _ = execute(action, snapshot: snapshot)
        }
        closeRemainingPosition()
    }
}
