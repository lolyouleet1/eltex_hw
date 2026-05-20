import Foundation

protocol P2PDataMapperProtocol: AnyObject {
    func makeCurrencies(from apiCurrencies: [APICurrency]) -> [Currency]
    func makeRate(from rateDTO: CurrencyPairRateDTO) -> P2PCurrencyPairRate
    func makeExchangeRequest(
        offer: P2POffer,
        sendCurrencyCode: String,
        receiveCurrencyCode: String,
        sendAmount: Float,
        receiveAmount: Float
    ) -> P2PExchangeRequest
}

final class P2PDataMapper: P2PDataMapperProtocol {
    // MARK: - Public Methods
    func makeCurrencies(from apiCurrencies: [APICurrency]) -> [Currency] {
        apiCurrencies.map {
            Currency(
                id: $0.id,
                code: $0.code,
                baseValue: Constants.defaultBaseValue,
                type: Constants.defaultCurrencyType,
                isFavorite: Constants.defaultIsFavorite
            )
        }
    }
    
    func makeRate(from rateDTO: CurrencyPairRateDTO) -> P2PCurrencyPairRate {
        P2PCurrencyPairRate(
            baseCurrencyCode: rateDTO.base,
            receiveCurrencyCode: rateDTO.quote,
            rate: rateDTO.rate
        )
    }
    
    func makeExchangeRequest(
        offer: P2POffer,
        sendCurrencyCode: String,
        receiveCurrencyCode: String,
        sendAmount: Float,
        receiveAmount: Float
    ) -> P2PExchangeRequest {
        P2PExchangeRequest(
            offer: offer,
            sendCurrencyCode: sendCurrencyCode,
            receiveCurrencyCode: receiveCurrencyCode,
            sendAmount: sendAmount,
            receiveAmount: receiveAmount
        )
    }
}

// MARK: - Constants
private extension P2PDataMapper {
    enum Constants {
        static let defaultBaseValue: Float = 0
        static let defaultCurrencyType: CurrencyType = .fiat
        static let defaultIsFavorite = false
    }
}
