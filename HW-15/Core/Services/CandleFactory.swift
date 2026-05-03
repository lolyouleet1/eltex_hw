import Foundation

enum CandlestickFactory {
    static func makeCandlesticks(from operations: [Operation]) -> [Candlestick] {
        guard let firstOperation = operations.first else { return [] }
        
        var previousClose = firstOperation.price
        
        return operations.map { operation in
            let open = previousClose
            let close = operation.price
            let spreadOffset = max(
                Float(abs(operation.snapshot.spread)) / Constants.highValueDivisor,
                Constants.minimumRangeOffset
            )
            let lowOffset = max(
                Float(abs(operation.snapshot.spread)) / Constants.lowValueDivisor,
                Constants.minimumRangeOffset
            )
            
            previousClose = close
            
            return Candlestick(
                open: open,
                close: close,
                high: max(open, close) + spreadOffset,
                low: max(Constants.minimumPrice, min(open, close) - lowOffset),
                recommendation: operation.operationType
            )
        }
    }
}

// MARK: - Constants
private extension CandlestickFactory {
    enum Constants {
        static let highValueDivisor: Float = 900
        static let lowValueDivisor: Float = 1_200
        static let minimumRangeOffset: Float = 1
        static let minimumPrice: Float = 0
    }
}
