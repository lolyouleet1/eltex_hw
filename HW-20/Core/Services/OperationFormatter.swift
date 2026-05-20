import Foundation

final class OperationFormatter {
    // MARK: - Public Methods
    func makeTextForBot(for dayResult: BotDayResult) -> String {
        let botName = dayResult.botName
        let currencyPair = dayResult.currencyPair
        let day = dayResult.day
        let income = signedText(from: dayResult.income)
        let incomeCurrencyCode = dayResult.incomeCurrencyCode

        return "\(botName) (\(currencyPair)), day = \(day), income = \(income) \(incomeCurrencyCode)"
    }
    
    func makeTotalIncomeText(currencyCode: String, income: Float) -> String {
        "\(Constants.totalIncomeTitle)\(signedText(from: income)) \(currencyCode)"
    }
    
    func makeRunSummaryText(botsCount: Int, daysCount: Int, rowsCount: Int) -> String {
        "\(Constants.summaryTitle)bots = \(botsCount), days = \(daysCount), results = \(rowsCount)"
    }
    
    func makeWalletBalanceText(for item: WalletBalanceItem) -> String {
        let balanceText = AppConfiguration.PriceFormatting.string(from: item.balance)
        let creditText = AppConfiguration.PriceFormatting.string(from: item.credit)
        
        return "\(Constants.balanceTitle)\(item.currencyCode): \(balanceText), credit = \(creditText)"
    }
}

// MARK: - Private Methods
private extension OperationFormatter {
    func signedText(from value: Float) -> String {
        let text = AppConfiguration.PriceFormatting.string(from: value)
        
        return value >= .zero ? "+\(text)" : text
    }
}

// MARK: - Constants
private extension OperationFormatter {
    enum Constants {
        static let totalIncomeTitle = "Total income: "
        static let summaryTitle = "Summary: "
        static let balanceTitle = "Wallet balance "
    }
}
