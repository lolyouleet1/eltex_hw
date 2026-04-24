import Foundation

final class Wallet {
    // MARK: - UI
    private var balances: [String : Float] = [:]
    private var credits: [String : Float] = [:]
    
    // MARK: - Concurrency
    private let queue = DispatchQueue(label: "wallet.queue")
    
    init(startBalance: [String : Float], startCredits: [String : Float]) {
        self.balances = startBalance
        self.credits = startCredits
    }
    
    // MARK: - Public Methods
    func buy(base: Currency, quote: Currency, price: Float, amount: Int) {
        let fullBuyPrice = price * Float(amount)
        
        queue.sync {
            if fullBuyPrice > balances[quote.code, default: 0] {
                let maxBaseValue = AppConfiguration.TradeBotSettings.maxCurrencyBaseValue
                let maxBuyAmount = AppConfiguration.TradeBotSettings.maxBuyAmount
                credits[quote.code, default: 0] += maxBaseValue * Float(maxBuyAmount)
                balances[quote.code, default: 0] += maxBaseValue * Float(maxBuyAmount)
            }
            
            balances[base.code, default: 0] += Float(amount)
            balances[quote.code, default: 0] -= price * Float(amount)
        }
    }
    
    func sell(base: Currency, quote: Currency, price: Float, amount: Int) {
        queue.sync {
            if amount > Int(balances[base.code, default: 0]) {
                credits[base.code, default: 0] += 1000
                balances[base.code, default: 0] += 1000
            }
            
            balances[base.code, default: 0] -= Float(amount)
            balances[quote.code, default: 0] += price * Float(amount)
        }
    }
    
    func walletSnapshot() -> WalletSnapshot {
        queue.sync {
            let items = balances.keys.map { code in
                WalletBalanceItem(
                    currencyCode: code,
                    balance: balances[code, default: 0],
                    credit: credits[code, default: 0]
                )
            }
            
            return WalletSnapshot(items: items)
        }
    }
}
