import Foundation
import UIKit

struct Candlestick {
    let open: Double
    let close: Double
    let high: Double
    let low: Double
    let verticalOffset: CGFloat
    let recommendation: OperationType
    
    var isGrowing: Bool {
        close >= open
    }
}
