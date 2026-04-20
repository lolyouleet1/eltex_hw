import Foundation

enum AppConfiguration {
    enum Trading {
        static let startBalance: Float = 10_000
    }
    
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
}
