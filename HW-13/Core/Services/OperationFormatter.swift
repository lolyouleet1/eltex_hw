import Foundation

final class OperationFormatter {
    // MARK: - Public Methods
    func makeText(for operation: Operation) -> String {
        let priceText = AppConfiguration.PriceFormatting.string(from: operation.price)
        
        switch operation.operationType {
        case .buy:
            return "\(priceText)\(Constants.buyOperationSuffix)"
        case .sell:
            guard let startPrice = operation.startPrice,
                  let income = operation.income else {
                return "\(priceText)\(Constants.sellOperationSuffix)"
            }
            
            let startPriceText = AppConfiguration.PriceFormatting.string(from: startPrice)
            let incomeText = AppConfiguration.PriceFormatting.string(from: income)
            
            return """
            \(Constants.sellFromPrefix)\(startPriceText)\
            \(Constants.sellToSeparator)\(priceText)\
            \(Constants.sellIncomeSeparator)\(incomeText)
            """
        case .ignore:
            return "\(priceText)\(Constants.ignoreOperationSuffix)"
        }
    }
}

// MARK: - Constants
private extension OperationFormatter {
    enum Constants {
        static let buyOperationSuffix = " рублей - покупка"
        static let sellOperationSuffix = " рублей - продажа"
        static let ignoreOperationSuffix = " рублей - игнорирование"
        static let sellFromPrefix = "Продажа FROM = "
        static let sellToSeparator = " -> TO = "
        static let sellIncomeSeparator = ", INCOME = "
    }
}
