import Foundation
import UIKit

enum CandlestickFactory {
    static func makeCandlesticks(from operations: [Operation]) -> [CandlestickView] {
        var candlesticks: [CandlestickView] = []
        
        for index in operations.indices {
            let candlestick = CandlestickView()
            
            if index == 0 {
                candlestick.configure(previousPrice: 0, currentPrice: operations[index].price)
            } else {
                candlestick.configure(previousPrice: operations[index - 1].price, currentPrice: operations[index].price)
            }
            
            candlesticks.append(candlestick)
        }
        
        return candlesticks
    }
}
