// MARK: - Models
struct CurrencyPair {
    let base: Currency
    let quote: Currency
}

struct WalletBot {
    let name: String
    let pair: CurrencyPair
}

struct BotDayResult {
    let botName: String
    let currencyPair: String
    let day: Int
    let income: Float
    let incomeCurrencyCode: String
}

struct WalletBalanceItem {
    let currencyCode: String
    let balance: Float
    let credit: Float
}

struct WalletSnapshot {
    let items: [WalletBalanceItem]
}
