import Foundation
import CoreGraphics

final class GraphViewModel {
    struct ViewState {
        let activeMode: ChartType
        let candlesticks: [GraphCandlestickItemViewModel]
        let lines: [LineChartPointViewModel]
        let isEmpty: Bool
        let infoText: String
        let openText: String?
        let closeText: String?
        let highText: String?
        let lowText: String?
        let recommendationText: String
        let recommendationTone: RecommendationTone
    }
    
    // MARK: - Dependencies
    private let candlestickItems: [GraphCandlestickItemViewModel]
    private let pointItems: [LineChartPointViewModel]
    
    // MARK: - State
    private var selectedIndex: Int?
    private var recommendationIndex: Int?
    private(set) var viewState: ViewState
    private(set) var activeMode: ChartType = Constants.defaultChartType
    
    // MARK: - Lifecycle
    init(tradingResult: TradingRunResult?) {
        self.candlestickItems = Self.makeCandlestickItems(from: tradingResult?.candlesticks ?? [])
        self.pointItems = Self.makeLineItems(from: tradingResult?.lineChartPoints ?? [])
        self.viewState = ViewState(
            activeMode: activeMode,
            candlesticks: candlestickItems,
            lines: pointItems,
            isEmpty: candlestickItems.isEmpty || pointItems.isEmpty,
            infoText: Constants.pointInfoDefaultText,
            openText: nil,
            closeText: nil,
            highText: nil,
            lowText: nil,
            recommendationText: Constants.pointRecommendationDefaultText,
            recommendationTone: .neutral
        )
    }
    
    // MARK: - Public Methods
    func handleSelection(at index: Int) {
        guard isValidSelectionIndex(index) else { return }
        
        selectedIndex = index
        recommendationIndex = index
        rebuildState()
    }

    func changeActiveMode(to newMode: ChartType) {
        activeMode = newMode
        selectedIndex = nil
        recommendationIndex = nil
        rebuildState()
    }
}

// MARK: - Private Methods
private extension GraphViewModel {
    func rebuildState() {
        let candlestickModels = candlestickItems
        let pointModels = pointItems
        let recommendation = recommendationIndex.flatMap { index in
            switch activeMode {
            case .candlestick:
                return candlestickModels.indices.contains(index)
                    ? candlestickModels[index].candlestick.recommendation
                    : nil
            case .line:
                return pointModels.indices.contains(index)
                    ? pointModels[index].point.recommendation
                    : nil
            }
        }
        
        guard let selectedIndex, isValidSelectionIndex(selectedIndex) else {
            viewState = ViewState(
                activeMode: activeMode,
                candlesticks: candlestickModels,
                lines: pointModels,
                isEmpty: candlestickModels.isEmpty || pointModels.isEmpty,
                infoText: makeDefaultInfoText(),
                openText: nil,
                closeText: nil,
                highText: nil,
                lowText: nil,
                recommendationText: makeRecommendationText(from: recommendation),
                recommendationTone: makeRecommendationTone(from: recommendation)
            )
            
            return
        }
        
        switch activeMode {
        case .candlestick:
            let candlestick = candlestickModels[selectedIndex].candlestick
            viewState = ViewState(
                activeMode: activeMode,
                candlesticks: candlestickModels,
                lines: pointModels,
                isEmpty: candlestickModels.isEmpty || pointModels.isEmpty,
                infoText: Constants.infoTitle,
                openText: "\(Constants.openTitle)\(AppConfiguration.PriceFormatting.string(from: candlestick.open))",
                closeText: "\(Constants.closeTitle)\(AppConfiguration.PriceFormatting.string(from: candlestick.close))",
                highText: "\(Constants.highTitle)\(AppConfiguration.PriceFormatting.string(from: candlestick.high))",
                lowText: "\(Constants.lowTitle)\(AppConfiguration.PriceFormatting.string(from: candlestick.low))",
                recommendationText: makeRecommendationText(from: recommendation),
                recommendationTone: makeRecommendationTone(from: recommendation)
            )
        case .line:
            let point = pointModels[selectedIndex].point
            viewState = ViewState(
                activeMode: activeMode,
                candlesticks: candlestickModels,
                lines: pointModels,
                isEmpty: candlestickModels.isEmpty || pointModels.isEmpty,
                infoText: Constants.infoTitle,
                openText: "\(Constants.priceTitle)\(AppConfiguration.PriceFormatting.string(from: point.value))",
                closeText: nil,
                highText: nil,
                lowText: nil,
                recommendationText: makeRecommendationText(from: recommendation),
                recommendationTone: makeRecommendationTone(from: recommendation)
            )
        }
    }
    
    func isValidSelectionIndex(_ index: Int) -> Bool {
        switch activeMode {
        case .candlestick:
            return candlestickItems.indices.contains(index)
        case .line:
            return pointItems.indices.contains(index)
        }
    }
    
    func makeRecommendationText(from recommendation: OperationType?) -> String {
        guard let recommendation else {
            return activeMode == .candlestick
                ? Constants.candlestickRecommendationDefaultText
                : Constants.pointRecommendationDefaultText
        }

        return "\(Constants.recommendationTitle)\(recommendationText(for: recommendation))"
    }
    
    func makeRecommendationTone(from recommendation: OperationType?) -> RecommendationTone {
        guard let recommendation else { return .neutral }

        return recommendationTone(for: recommendation)
    }
    
    func makeDefaultInfoText() -> String {
        activeMode == .candlestick
            ? Constants.candlestickInfoDefaultText
            : Constants.pointInfoDefaultText
    }
    
    static func makeCandlestickItems(from candlesticks: [Candlestick]) -> [GraphCandlestickItemViewModel] {
        guard !candlesticks.isEmpty else { return [] }
        
        var currentOffset = CGFloat.random(
            in: Constants.minimumVerticalOffset...Constants.maximumVerticalOffset
        )
        
        return candlesticks.map { candlestick in
            currentOffset += CGFloat.random(
                in: -Constants.verticalOffsetStep...Constants.verticalOffsetStep
            )
            currentOffset = min(
                max(currentOffset, Constants.minimumVerticalOffset),
                Constants.maximumVerticalOffset
            )
            
            let tailHeight = CGFloat.random(
                in: Constants.minimumTailHeight...Constants.maximumTailHeight
            )
            let maximumBodyHeight = min(
                Constants.maximumBodyHeight,
                tailHeight - Constants.minimumTailToBodyDifference
            )
            let bodyHeight = CGFloat.random(
                in: Constants.minimumBodyHeight...maximumBodyHeight
            )
            
            return GraphCandlestickItemViewModel(
                candlestick: candlestick,
                bodyHeight: bodyHeight,
                tailHeight: tailHeight,
                verticalOffset: currentOffset
            )
        }
    }
    
    static func makeLineItems(from points: [LineChartPoint]) -> [LineChartPointViewModel] {
        guard !points.isEmpty else { return [] }
        
        return points.map { point in
            LineChartPointViewModel(
                point: point,
                size: Constants.pointSize
            )
        }
    }
    
    func recommendationText(for recommendation: OperationType) -> String {
        switch recommendation {
        case .buy:
            return Constants.buyRecommendationText
        case .sell:
            return Constants.sellRecommendationText
        case .ignore:
            return Constants.ignoreRecommendationText
        }
    }
    
    func recommendationTone(for recommendation: OperationType) -> RecommendationTone {
        switch recommendation {
        case .buy:
            return .buy
        case .sell:
            return .sell
        case .ignore:
            return .ignore
        }
    }
}

// MARK: - Constants
private extension GraphViewModel {
    enum Constants {
        static let infoTitle = "INFO:"
        static let openTitle = "Open: "
        static let closeTitle = "Close: "
        static let highTitle = "High: "
        static let lowTitle = "Low: "
        static let priceTitle = "Price: "
        static let recommendationTitle = "Recommendation: "
        static let buyRecommendationText = "BUY"
        static let sellRecommendationText = "SELL"
        static let ignoreRecommendationText = "IGNORE"
        static let minimumTailHeight: CGFloat = 70
        static let maximumTailHeight: CGFloat = 110
        static let minimumBodyHeight: CGFloat = 16
        static let maximumBodyHeight: CGFloat = 60
        static let minimumTailToBodyDifference: CGFloat = 12
        static let minimumVerticalOffset: CGFloat = -18
        static let maximumVerticalOffset: CGFloat = 18
        static let verticalOffsetStep: CGFloat = 10
        static let pointSize: CGFloat = 8
        static let defaultChartType: ChartType = .line
        static let candlestickRecommendationDefaultText = "Choose candlestick to get recommendation"
        static let pointRecommendationDefaultText = "Choose point to get recommendation"
        static let candlestickInfoDefaultText = "Choose candlestick to get info"
        static let pointInfoDefaultText = "Choose point to get info"
    }
}
