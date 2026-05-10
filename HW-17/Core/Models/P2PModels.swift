import Foundation

// MARK: - Models
struct APICurrency {
    let id: UUID
    let code: String
    let name: String
}

struct P2POffer {
    let id: UUID
    let sellerName: String
    let rate: Float
    let reserve: Float
    let receiveCurrencyCode: String
}

struct P2PExchangeRequest {
    let offer: P2POffer
    let sendCurrencyCode: String
    let receiveCurrencyCode: String
    let sendAmount: Float
    let receiveAmount: Float
}

struct P2PExchangeResult {
    let sendCurrencyCode: String
    let receiveCurrencyCode: String
    let sendAmount: Float
    let receiveAmount: Float
}

// MARK: - DTO
struct FloatRatesRateDTO: Decodable {
    let code: String
    let name: String
    let rate: Float
    let date: String
}

struct CurrencyPairRateDTO {
    let date: String
    let base: String
    let quote: String
    let rate: Float
}

// MARK: - Errors
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noInternet
    case serviceUnavailable
    case parsingFailed
    case accessDenied
    case serverError
    case operationFailed
}
