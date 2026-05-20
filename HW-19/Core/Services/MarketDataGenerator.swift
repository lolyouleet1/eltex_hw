import Foundation

protocol MarketDataGenerator {
    func makeSnapshot() -> MarketSnapshot
}

final class MockMarketDataGenerator: MarketDataGenerator {
    // MARK: - Public Methods
    func makeSnapshot() -> MarketSnapshot {
        MarketSnapshot(
            currentPrice: Float.random(in: Constants.minimumPrice...Constants.maximumPrice),
            buyOrders: Int.random(in: Constants.minimumOrders...Constants.maximumOrders),
            sellOrders: Int.random(in: Constants.minimumOrders...Constants.maximumOrders)
        )
    }
}

// MARK: - Constants
private extension MockMarketDataGenerator {
    enum Constants {
        static let minimumPrice: Float = 100
        static let maximumPrice: Float = 200
        static let minimumOrders: Int = 0
        static let maximumOrders: Int = 10_000
    }
}
