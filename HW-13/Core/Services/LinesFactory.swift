import Foundation

enum LinesFactory {
    // MARK: - Public Methods
    static func makeLinePoints(from operations: [Operation]) -> [LineChartPoint] {
        operations.enumerated().map { index, operation in
            LineChartPoint(
                id: UUID(),
                value: operation.price,
                index: index,
                recommendation: operation.operationType
            )
        }
    }
    
    static func getMaxAndMinPrice(from points: [LineChartPointViewModel]) -> ChartPriceRange {
        guard !points.isEmpty else { return ChartPriceRange(minPrice: .zero, maxPrice: .zero) }
        
        let values = points.map { $0.point.value }
        let minPrice = values.min() ?? .zero
        let maxPrice = values.max() ?? .zero
        
        return ChartPriceRange(minPrice: minPrice, maxPrice: maxPrice)
    }
}
