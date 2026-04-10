import Foundation

enum OperationsAmount {
    case small
    case medium
    case large
    
    var amount: Int {
        switch self {
        case .small:
            return Int.random(in: 1..<20)
        case .medium:
            return Int.random(in: 20..<40)
        case .large:
            return Int.random(in: 40..<80)
        }
    }
}

enum Action {
    case buy
    case sell
    case ignore
}

struct MarketSnapshot {
    let currentPrice: Double
    let buyOrders: Int
    let sellOrders: Int

    var spread: Int {
        sellOrders - buyOrders
    }

    var wantsToSell: Bool {
        sellOrders > buyOrders
    }
}

enum OperationType {
    case buy
    case sell
    case ignore
}

struct Operation {
    let id: UUID
    let text: String
    let operationType: OperationType
    let price: Double
}
