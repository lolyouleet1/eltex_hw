import Foundation

enum AppConfiguration {
    // MARK: - Trading
    enum Trading {
        static let startBalance: Float = 10_000
        static let startCredit: Float = 0
        static let creditRefillAmount: Float = 1_000
    }
    
    // MARK: - Price Formatting
    enum PriceFormatting {
        static let minimumFractionDigits = 2
        static let maximumFractionDigits = 2
        
        private static let roundingMultiplier: Float = 100
        private static let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = minimumFractionDigits
            formatter.maximumFractionDigits = maximumFractionDigits
            return formatter
        }()
        
        static func rounded(_ value: Float) -> Float {
            (value * roundingMultiplier).rounded() / roundingMultiplier
        }
        
        static func string(from value: Float) -> String {
            let roundedValue = rounded(value)
            return formatter.string(from: NSNumber(value: roundedValue)) ?? String(roundedValue)
        }
    }
    
    // MARK: - Trade Bot Settings
    enum TradeBotSettings {
        static let minOperationsPerDay: Int = 100
        static let maxOperationsPerDay: Int = 1000
        static let workingDays: Int = 365
        static let minBuyAmount: Int = 1
        static let maxBuyAmount: Int = 10
        static let minCurrencyBaseValue: Float = 0.01
        static let maxCurrencyBaseValue: Float = 100
    }
}
