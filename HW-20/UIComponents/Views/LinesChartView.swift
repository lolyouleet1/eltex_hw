import UIKit

protocol PointSelectedProtocol: AnyObject {
    func didTappedPoint(at index: Int)
}

final class LinesChartView: UIView {
    // MARK: - UI
    private var points: [UIView] = []
    private var priceLabels: [UILabel] = []
    
    // MARK: - Delegate
    weak var delegate: PointSelectedProtocol?
    
    // MARK: - Dependencies
    private let viewModel: GraphViewModel
    
    // MARK: - State
    private var didSetupPoints = false
    private var selectedPoint: UIView?
    
    // MARK: - Lifecycle
    init(frame: CGRect, viewModel: GraphViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        backgroundColor = Constants.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds.width > .zero, bounds.height > .zero else { return }
        guard !didSetupPoints else { return }
        
        didSetupPoints = true
        setupPoints()
    }
    
    // MARK: - Public Methods
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let plotSize = makePlotSize()
        drawGraphLines()
        drawDashLines(plotSize: plotSize)
    }
    
    func disablePointSelection() {
        selectedPoint?.transform = .identity
        selectedPoint?.backgroundColor = Constants.pointDefaultColor
        selectedPoint?.layer.borderWidth = Constants.clearedBorderWidth
        selectedPoint?.layer.borderColor = Constants.clearedBorderColor
        selectedPoint = nil
    }
    
    func reloadData() {
        disablePointSelection()
        didSetupPoints = false
        setNeedsLayout()
        layoutIfNeeded()
        setNeedsDisplay()
    }
}

// MARK: - Setup
private extension LinesChartView {
    func clearPriceLabels() {
        priceLabels.forEach { $0.removeFromSuperview() }
        priceLabels.removeAll()
    }
    
    func setupPriceLabels() {
        for label in priceLabels {
            addSubview(label)
        }
    }
    
    func addPointsToHierarchy() {
        for point in points {
            addSubview(point)
        }
    }
    
    func setupPointsHandler() {
        guard !points.isEmpty else { return }
        
        for point in points {
            let gesture = UITapGestureRecognizer(
                target: self,
                action: #selector(handlePointTapped(_:))
            )
            point.addGestureRecognizer(gesture)
        }
    }
}

// MARK: - Private Methods
private extension LinesChartView {
    func setupPoints() {
        clearPoints()
        
        let lines = viewModel.viewState.lines

        guard !lines.isEmpty else { return }

        let plotSize = makePlotSize()
        let priceRange = LinesFactory.getMaxAndMinPrice(from: lines)
        
        if lines.count == Constants.singlePointCount {
            setupSinglePoint(lines: lines, plotSize: plotSize)
        } else if priceRange.maxPrice == priceRange.minPrice {
            setupHorizontalLinePoints(lines: lines, plotSize: plotSize)
        } else {
            setupRegularPoints(lines: lines, plotSize: plotSize, priceRange: priceRange)
        }
        
        addPointsToHierarchy()
        setupPointsHandler()
        
        DispatchQueue.main.async {
            self.setupLastPointAnimation()
        }
    }
    
    func clearPoints() {
        points.forEach { $0.removeFromSuperview() }
        points.removeAll()
        clearPriceLabels()
    }
    
    func makePlotSize() -> CGSize {
        CGSize(
            width: bounds.width - Constants.horizontalPaddingsSum,
            height: bounds.height - Constants.verticalPaddingMultiplier * Constants.verticalPadding
        )
    }

    func setupSinglePoint(lines: [LineChartPointViewModel], plotSize: CGSize) {
        let xPos = Constants.leftPadding + plotSize.width / Constants.centerPositionDivisor
        let yPos = Constants.verticalPadding + plotSize.height / Constants.centerPositionDivisor
        let index = Constants.firstItemIndex
        
        let pointView = makePointView(
            x: xPos,
            y: yPos,
            size: lines[index].size,
            index: index
        )
        points.append(pointView)
    }

    func setupHorizontalLinePoints(lines: [LineChartPointViewModel], plotSize: CGSize) {
        for index in lines.indices {
            let xPos = Constants.leftPadding + CGFloat(index) / CGFloat(lines.count - Constants.lastPointIndexOffset) * plotSize.width
            let yPos = Constants.verticalPadding + plotSize.height / Constants.centerPositionDivisor

            let pointView = makePointView(
                x: xPos,
                y: yPos,
                size: lines[index].size,
                index: index
            )
            points.append(pointView)
        }
    }

    func setupRegularPoints(lines: [LineChartPointViewModel], plotSize: CGSize, priceRange: ChartPriceRange) {
        for index in lines.indices {
            let xPos = Constants.leftPadding + CGFloat(index) / CGFloat(lines.count - Constants.lastPointIndexOffset) * plotSize.width
            
            let normalizedY = CGFloat(lines[index].point.value - priceRange.minPrice) / CGFloat(priceRange.maxPrice - priceRange.minPrice)
            let yPos = Constants.verticalPadding + (Constants.maximumNormalizedValue - normalizedY) * plotSize.height

            let pointView = makePointView(
                x: xPos,
                y: yPos,
                size: lines[index].size,
                index: index
            )
            points.append(pointView)
        }
    }

    func makePointView(x: CGFloat, y: CGFloat, size: CGFloat, index: Int) -> UIView {
        let view = UIView()
        view.backgroundColor = Constants.pointDefaultColor
        view.frame = CGRect(
            x: x - size / Constants.centerPositionDivisor,
            y: y - size / Constants.centerPositionDivisor,
            width: size,
            height: size
        )
        view.layer.cornerRadius = size / Constants.centerPositionDivisor
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        view.tag = index

        return view
    }
    
    func drawGraphLines() {
        guard points.count >= Constants.minimumLinePointCount else { return }
        
        let path = UIBezierPath()
        guard let firstPoint = points.first else { return }
        
        path.move(to: firstPoint.center)
        
        for point in points.dropFirst() {
            path.addLine(to: point.center)
        }
        
        Constants.graphLineColor.setStroke()
        path.lineWidth = Constants.graphLineWidth
        
        path.stroke()
    }
    
    func drawDashLines(plotSize: CGSize) {
        guard !points.isEmpty else { return }
        
        let lines = viewModel.viewState.lines
        guard !lines.isEmpty else { return }
             
        drawHorizontalDashLines(plotSize: plotSize, lines: lines)
        drawVerticalDashLines(plotSize: plotSize)
    }
    
    func drawHorizontalDashLines(plotSize: CGSize, lines: [LineChartPointViewModel]) {
        fillPriceLabels()
        let priceRange = LinesFactory.getMaxAndMinPrice(from: lines)
        
        if priceRange.minPrice == priceRange.maxPrice {
            let yPos = Constants.verticalPadding + plotSize.height / Constants.centerPositionDivisor
            drawHorizontalDashLine(at: yPos, plotSize: plotSize)
            configurePriceLabel(
                priceLabels[Constants.firstItemIndex],
                text: makePriceText(from: priceRange.maxPrice),
                yPosition: yPos
            )
        } else {
            let spread = (priceRange.maxPrice - priceRange.minPrice) / Float(Constants.priceLevelSegmentCount)
            let priceLevels = (0..<Constants.priceLabelCount).map { index in
                priceRange.minPrice + Float(index) * spread
            }
            
            for index in priceLevels.indices {
                let normalizedY = CGFloat(priceLevels[index] - priceRange.minPrice) / CGFloat(priceRange.maxPrice - priceRange.minPrice)
                let yPos = Constants.verticalPadding + (Constants.maximumNormalizedValue - normalizedY) * plotSize.height
                drawHorizontalDashLine(at: yPos, plotSize: plotSize)
                configurePriceLabel(
                    priceLabels[index],
                    text: makePriceText(from: priceLevels[index]),
                    yPosition: yPos
                )
            }
        }
        
        setupPriceLabels()
    }
    
    func drawVerticalDashLines(plotSize: CGSize) {
        for point in points {
            let xPos = point.center.x
            let yStart = Constants.verticalPadding
            let yEnd: CGFloat = plotSize.height + Constants.verticalPadding
            
            let dashLine = UIBezierPath()
            dashLine.move(to: CGPoint(x: xPos, y: yStart))
            dashLine.addLine(to: CGPoint(x: xPos, y: yEnd))
            
            dashLine.lineWidth = Constants.graphLineWidth
            dashLine.setLineDash(
                Constants.dashPattern,
                count: Constants.dashPattern.count,
                phase: .zero
            )
            
            Constants.gridLineColor.setStroke()
            dashLine.stroke()
        }
    }
    
    func fillPriceLabels() {
        clearPriceLabels()
        
        priceLabels = (0..<Constants.priceLabelCount).map { _ in
            let label = UILabel()
            label.font = .systemFont(ofSize: Constants.priceLabelFontSize)
            return label
        }
    }
    
    func drawHorizontalDashLine(at yPosition: CGFloat, plotSize: CGSize) {
        let dashLine = UIBezierPath()
        dashLine.move(to: CGPoint(x: Constants.leftPadding, y: yPosition))
        dashLine.addLine(to: CGPoint(x: plotSize.width + Constants.leftPadding, y: yPosition))
        dashLine.lineWidth = Constants.graphLineWidth
        dashLine.setLineDash(
            Constants.dashPattern,
            count: Constants.dashPattern.count,
            phase: .zero
        )
        
        Constants.gridLineColor.setStroke()
        dashLine.stroke()
    }
    
    func configurePriceLabel(_ label: UILabel, text: String, yPosition: CGFloat) {
        label.text = text
        label.frame = CGRect(
            x: .zero,
            y: yPosition,
            width: Constants.priceLabelWidth,
            height: Constants.priceLabelHeight
        )
    }
    
    func makePriceText(from value: Float) -> String {
        AppConfiguration.PriceFormatting.string(from: value)
    }
    
    func setupLastPointAnimation() {
        let lastPoint = points[points.count - Constants.lastPointIndexOffset]
        
        lastPoint.layer.borderWidth = Constants.lastPointBorderWidth
        lastPoint.layer.borderColor = Constants.lastPointBorderColor
        
        UIView.animate(
            withDuration: Constants.lastPointAnimationDuration,
            delay: Constants.lastPointAnimationDelay,
            options: [.autoreverse, .repeat],
            animations: {
                lastPoint.alpha = Constants.lastPointAnimatedAlpha
            },
            completion: nil
        )
    }
}

// MARK: - Handlers
private extension LinesChartView {
    @objc func handlePointTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedPoint = gesture.view else { return }
        
        disablePointSelection()
        
        tappedPoint.transform = CGAffineTransform(scaleX: Constants.tappedPointScale, y: Constants.tappedPointScale)
        tappedPoint.backgroundColor = Constants.tappedPointBackgroundColor
        tappedPoint.layer.borderWidth = Constants.tappedPointBorderWidth
        tappedPoint.layer.borderColor = Constants.tappedPointBorderColor
        
        selectedPoint = tappedPoint
        
        delegate?.didTappedPoint(at: tappedPoint.tag)
    }
}

// MARK: - Constants
private extension LinesChartView {
    enum Constants {
        static let singlePointCount = 1
        static let firstItemIndex = 0
        static let lastPointIndexOffset = 1
        static let minimumLinePointCount = 2
        static let priceLabelCount = 5
        static let priceLevelSegmentCount = priceLabelCount - 1
        static let centerPositionDivisor: CGFloat = 2
        static let verticalPaddingMultiplier: CGFloat = 2
        static let maximumNormalizedValue: CGFloat = 1
        static let backgroundColor: UIColor = .secondarySystemBackground
        static let graphLineColor: UIColor = .black
        static let gridLineColor: UIColor = .black
        static let dashPattern: [CGFloat] = [4, 2]
        static let leftPadding: CGFloat = 40
        static let rightPadding: CGFloat = 7
        static let horizontalPaddingsSum: CGFloat = leftPadding + rightPadding
        static let verticalPadding: CGFloat = 10
        static let graphLineWidth: CGFloat = 1
        static let priceLabelWidth: CGFloat = leftPadding - 5
        static let priceLabelHeight: CGFloat = 10
        static let priceLabelFontSize: CGFloat = 10
        static let pointDefaultColor: UIColor = .black
        static let clearedBorderWidth: CGFloat = .zero
        static let clearedBorderColor: CGColor = UIColor.clear.cgColor
        static let tappedPointScale: CGFloat = 1.7
        static let tappedPointBackgroundColor: UIColor = .white
        static let tappedPointBorderWidth: CGFloat = 1
        static let tappedPointBorderColor: CGColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1).cgColor
        static let lastPointBorderColor: CGColor = UIColor(red: 0.31, green: 0.25, blue: 0.79, alpha: 1).cgColor
        static let lastPointBorderWidth: CGFloat = 2
        static let lastPointAnimationDuration: TimeInterval = 0.5
        static let lastPointAnimationDelay: TimeInterval = 0
        static let lastPointAnimatedAlpha: CGFloat = 0.5
    }
}
