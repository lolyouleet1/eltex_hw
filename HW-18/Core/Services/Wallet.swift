import Foundation

final class Wallet {
    // MARK: - State
    private var balances: [String: Float] = [:]
    private var credits: [String: Float] = [:]
    
    // MARK: - Concurrency
    private let queue = DispatchQueue(label: Constants.queueLabel)
    
    // MARK: - Lifecycle
    init(startBalance: [String: Float], startCredits: [String: Float]) {
        self.balances = startBalance
        self.credits = startCredits
    }
    
    // MARK: - Public Methods
    func buy(base: Currency, quote: Currency, price: Float, amount: Int) {
        let fullBuyPrice = price * Float(amount)
        
        queue.sync {
            if fullBuyPrice > balances[quote.code, default: .zero] {
                credits[quote.code, default: .zero] += AppConfiguration.Trading.creditRefillAmount
                balances[quote.code, default: .zero] += AppConfiguration.Trading.creditRefillAmount
            }
            
            balances[base.code, default: .zero] += Float(amount)
            balances[quote.code, default: .zero] -= price * Float(amount)
        }
    }
    
    func sell(base: Currency, quote: Currency, price: Float, amount: Int) {
        queue.sync {
            if amount > Int(balances[base.code, default: .zero]) {
                credits[base.code, default: .zero] += AppConfiguration.Trading.creditRefillAmount
                balances[base.code, default: .zero] += AppConfiguration.Trading.creditRefillAmount
            }
            
            balances[base.code, default: .zero] -= Float(amount)
            balances[quote.code, default: .zero] += price * Float(amount)
        }
    }
    
    func balance(for currencyCode: String) -> Float {
        queue.sync {
            balances[currencyCode, default: .zero]
        }
    }
    
    @discardableResult
    func exchange(sendCurrencyCode: String, receiveCurrencyCode: String, sendAmount: Float, receiveAmount: Float) -> Bool {
        queue.sync {
            guard sendAmount > .zero,
                  receiveAmount > .zero,
                  balances[sendCurrencyCode, default: .zero] >= sendAmount else {
                return false
            }
            
            balances[sendCurrencyCode, default: .zero] -= sendAmount
            balances[receiveCurrencyCode, default: .zero] += receiveAmount
            
            return true
        }
    }
    
    func walletSnapshot() -> WalletSnapshot {
        queue.sync {
            let items = balances.keys.map { code in
                WalletBalanceItem(
                    currencyCode: code,
                    balance: balances[code, default: .zero],
                    credit: credits[code, default: .zero]
                )
            }
            
            return WalletSnapshot(items: items)
        }
    }
}

// MARK: - Constants
private extension Wallet {
    enum Constants {
        static let queueLabel = "wallet.queue"
    }
}
