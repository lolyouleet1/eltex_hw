import Foundation
import CoreGraphics

enum CandlestickFactory {
    static func makeCandlesticks(from operations: [Operation]) -> [Candlestick] {
        var result: [Candlestick] = []
        
        for _ in operations {
            let open = Double.random(in: 80...120)
            let close = Double.random(in: 80...120)
            let high = max(open, close) + Double.random(in: 1...15)
            let low = min(open, close) - Double.random(in: 1...15)
            let verticalOffset = CGFloat.random(in: -40...40)
            
            let candlestick = Candlestick(
                open: open,
                close: close,
                high: high,
                low: low,
                verticalOffset: verticalOffset,
                recommendation: OperationType.random
            )
            
            result.append(candlestick)
        }
        
        return result
    }
}
