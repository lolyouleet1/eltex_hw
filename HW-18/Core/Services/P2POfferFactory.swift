import Foundation

final class P2POfferFactory {
    // MARK: - Public Methods
    func makeOffers(rate: Float, receiveCurrencyCode: String) -> [P2POffer] {
        Constants.sellerNames.map { sellerName in
            let discount = Float.random(in: Constants.minDiscount...Constants.maxDiscount)
            let offerRate = AppConfiguration.PriceFormatting.rounded(rate * (Constants.fullRateMultiplier - discount))
            let reserve = AppConfiguration.PriceFormatting.rounded(
                Float.random(in: Constants.minReserve...Constants.maxReserve)
            )
            
            return P2POffer(
                id: UUID(),
                sellerName: sellerName,
                rate: offerRate,
                reserve: reserve,
                receiveCurrencyCode: receiveCurrencyCode
            )
        }
        .sorted { $0.rate > $1.rate }
    }
}

// MARK: - Constants
private extension P2POfferFactory {
    enum Constants {
        static let sellerNames = [
            "Alex Market",
            "Swift Change",
            "Green Desk",
            "Nova Trade",
            "Fast Pair",
            "Limit Hub",
            "Rate Point",
            "Cash Bridge"
        ]
        static let minDiscount: Float = 0.01
        static let maxDiscount: Float = 0.08
        static let fullRateMultiplier: Float = 1
        static let minReserve: Float = 500
        static let maxReserve: Float = 100_000
    }
}
