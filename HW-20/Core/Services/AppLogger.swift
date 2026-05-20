import Foundation
import OSLog

protocol AppLoggerProtocol: AnyObject {
    func info(_ message: String, metadata: [String: String])
    func warning(_ message: String, metadata: [String: String])
    func error(_ message: String, metadata: [String: String])
}

extension AppLoggerProtocol {
    func info(_ message: String) {
        info(message, metadata: [:])
    }
    
    func warning(_ message: String) {
        warning(message, metadata: [:])
    }
    
    func error(_ message: String) {
        error(message, metadata: [:])
    }
}

final class AppLogger: AppLoggerProtocol {
    // MARK: - Models
    enum Category {
        case authorization
        case p2pTrading
        case network
    }
    
    // MARK: - Dependencies
    private let logger: Logger
    
    // MARK: - Lifecycle
    init(category: Category) {
        self.logger = Logger(
            subsystem: Constants.subsystem,
            category: category.name
        )
    }
    
    // MARK: - Public Methods
    static let authorization = AppLogger(category: .authorization)
    static let p2pTrading = AppLogger(category: .p2pTrading)
    static let network = AppLogger(category: .network)
    
    func info(_ message: String, metadata: [String: String] = [:]) {
        logger.log(level: .info, "\(self.makeMessage(message, metadata: metadata), privacy: .public)")
    }
    
    func warning(_ message: String, metadata: [String: String] = [:]) {
        logger.log(level: .default, "\(self.makeMessage(message, metadata: metadata), privacy: .public)")
    }
    
    func error(_ message: String, metadata: [String: String] = [:]) {
        logger.log(level: .error, "\(self.makeMessage(message, metadata: metadata), privacy: .public)")
    }
}

// MARK: - Private Methods
private extension AppLogger {
    func makeMessage(_ message: String, metadata: [String: String]) -> String {
        guard !metadata.isEmpty else { return message }
        
        let metadataText = metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)\(Constants.keyValueSeparator)\($0.value)" }
            .joined(separator: Constants.metadataSeparator)
        
        return "\(message)\(Constants.metadataPrefix)\(metadataText)"
    }
}

// MARK: - Constants
fileprivate extension AppLogger {
    enum Constants {
        static let subsystem = "ELTEX.HW-20"
        static let authorizationCategory = "Authorization"
        static let p2pTradingCategory = "P2PTrading"
        static let networkCategory = "Network"
        static let metadataPrefix = " | "
        static let metadataSeparator = ", "
        static let keyValueSeparator = "="
    }
}

// MARK: - AppLogger.Category
private extension AppLogger.Category {
    var name: String {
        switch self {
        case .authorization:
            return AppLogger.Constants.authorizationCategory
        case .p2pTrading:
            return AppLogger.Constants.p2pTradingCategory
        case .network:
            return AppLogger.Constants.networkCategory
        }
    }
}

// MARK: - Log Metadata
enum AppLogMetadataKey {
    static let amount = "amount"
    static let baseCurrency = "baseCurrency"
    static let count = "count"
    static let currency = "currency"
    static let error = "error"
    static let mode = "mode"
    static let offerID = "offerID"
    static let quoteCurrency = "quoteCurrency"
    static let reason = "reason"
    static let receiveAmount = "receiveAmount"
    static let receiveCurrency = "receiveCurrency"
    static let request = "request"
    static let reserve = "reserve"
    static let sendAmount = "sendAmount"
    static let sendCurrency = "sendCurrency"
    static let side = "side"
    static let status = "status"
    static let statusCode = "statusCode"
    static let strategy = "strategy"
    static let url = "url"
}

// MARK: - NetworkError
extension NetworkError {
    var logDescription: String {
        switch self {
        case .invalidURL:
            return Constants.invalidURL
        case .invalidResponse:
            return Constants.invalidResponse
        case .noInternet:
            return Constants.noInternet
        case .serviceUnavailable:
            return Constants.serviceUnavailable
        case .parsingFailed:
            return Constants.parsingFailed
        case .accessDenied:
            return Constants.accessDenied
        case .serverError:
            return Constants.serverError
        case .operationFailed:
            return Constants.operationFailed
        }
    }
}

// MARK: - Constants
private extension NetworkError {
    enum Constants {
        static let invalidURL = "invalidURL"
        static let invalidResponse = "invalidResponse"
        static let noInternet = "noInternet"
        static let serviceUnavailable = "serviceUnavailable"
        static let parsingFailed = "parsingFailed"
        static let accessDenied = "accessDenied"
        static let serverError = "serverError"
        static let operationFailed = "operationFailed"
    }
}

// MARK: - P2PExchangeError
extension P2PExchangeError {
    var logDescription: String {
        switch self {
        case .invalidAmount:
            return Constants.invalidAmount
        case .notEnoughMoney:
            return Constants.notEnoughMoney
        case .reserveIsTooLow:
            return Constants.reserveIsTooLow
        case .network(let error):
            return "\(Constants.networkPrefix)\(error.logDescription)"
        case .operationFailed:
            return Constants.operationFailed
        }
    }
}

// MARK: - Constants
private extension P2PExchangeError {
    enum Constants {
        static let invalidAmount = "invalidAmount"
        static let notEnoughMoney = "notEnoughMoney"
        static let reserveIsTooLow = "reserveIsTooLow"
        static let networkPrefix = "network."
        static let operationFailed = "operationFailed"
    }
}

// MARK: - SelectedSide
extension SelectedSide {
    var logDescription: String {
        switch self {
        case .left:
            return Constants.left
        case .right:
            return Constants.right
        }
    }
}

// MARK: - Constants
private extension SelectedSide {
    enum Constants {
        static let left = "left"
        static let right = "right"
    }
}
