import UIKit

final class GraphViewController: UIViewController {
    // MARK: - UI
    private let candlesChartView: CandlesChartView
    private let linesChartView: LinesChartView
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.emptyStateText
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let infoView = UIView()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.labelsFontSize)
        return label
    }()
    
    private let openLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.labelsFontSize)
        return label
    }()
    
    private let closeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.labelsFontSize)
        return label
    }()
    
    private let highLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.labelsFontSize)
        return label
    }()
    
    private let lowLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.labelsFontSize)
        return label
    }()
    
    private let recommendationView = UIView()
    private let recommendationAccentView = UIView()
    
    private let recommendationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.recommendationFontSize, weight: .medium)
        return label
    }()
    
    private let segmentedControl = UISegmentedControl(items: Constants.itemsInSegmentedControl)
    
    // MARK: - Dependencies
    private let viewModel: GraphViewModel
        
    // MARK: - Lifecycle
    init(viewModel: GraphViewModel) {
        self.viewModel = viewModel
        
        candlesChartView = CandlesChartView(frame: .zero, viewModel: viewModel)
        linesChartView = LinesChartView(frame: .zero, viewModel: viewModel)
        
        super.init(nibName: nil, bundle: nil)
        
        candlesChartView.delegate = self
        linesChartView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHierarchy()
        setupInfoView()
        setupRecommendationView()
        setupSegmentedControl()
        setupConstraints()
        render(viewModel.viewState)
    }
    
    func update(tradingResult: TradingRunResult?) {
        viewModel.update(tradingResult: tradingResult)
        
        render(viewModel.viewState)
        
        linesChartView.reloadData()
        candlesChartView.reloadData()
    }
}

// MARK: - Setup
private extension GraphViewController {
    func setupView() {
        view.backgroundColor = Constants.backgroundColor
    }
    
    func setupHierarchy() {
        view.addSubview(infoView)
        view.addSubview(candlesChartView)
        view.addSubview(linesChartView)
        view.addSubview(recommendationView)
        view.addSubview(emptyStateLabel)
        view.addSubview(segmentedControl)
    }
    
    func setupInfoView() {
        infoView.addSubview(infoLabel)
        infoView.addSubview(openLabel)
        infoView.addSubview(closeLabel)
        infoView.addSubview(highLabel)
        infoView.addSubview(lowLabel)
    }
    
    func setupRecommendationView() {
        recommendationView.layer.cornerRadius = Constants.recommendationCornerRadius
        recommendationView.layer.borderWidth = Constants.recommendationBorderWidth
        recommendationView.clipsToBounds = true
        
        recommendationAccentView.layer.cornerRadius = Constants.recommendationAccentSize / Constants.cornerRadiusDivisor
        
        recommendationView.addSubview(recommendationAccentView)
        recommendationView.addSubview(recommendationLabel)
    }
    
    func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = viewModel.viewState.activeMode.rawValue

        segmentedControl.addTarget(
            self,
            action: #selector(handleSegmentChanged),
            for: .valueChanged
        )
    }
}

// MARK: - Handlers
private extension GraphViewController {
    @objc func handleSegmentChanged() {
        guard let mode = ChartType(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        
        linesChartView.disablePointSelection()
        
        viewModel.changeActiveMode(to: mode)
        render(viewModel.viewState)
    }
}

// MARK: - Constraints
private extension GraphViewController {
    func setupConstraints() {
        candlesChartView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        openLabel.translatesAutoresizingMaskIntoConstraints = false
        closeLabel.translatesAutoresizingMaskIntoConstraints = false
        highLabel.translatesAutoresizingMaskIntoConstraints = false
        lowLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendationView.translatesAutoresizingMaskIntoConstraints = false
        recommendationAccentView.translatesAutoresizingMaskIntoConstraints = false
        recommendationLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        linesChartView.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.infoViewTopInset),
            infoView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.viewLeadingInset),
            
            infoLabel.topAnchor.constraint(equalTo: infoView.topAnchor, constant: Constants.labelVerticalInset),
            infoLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            infoLabel.widthAnchor.constraint(equalToConstant: Constants.infoLabelWidth),
            
            openLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: Constants.labelVerticalInset),
            openLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            openLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            openLabel.widthAnchor.constraint(equalToConstant: Constants.infoLabelWidth),
            
            closeLabel.topAnchor.constraint(equalTo: openLabel.bottomAnchor, constant: Constants.labelVerticalInset),
            closeLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            closeLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            closeLabel.widthAnchor.constraint(equalToConstant: Constants.infoLabelWidth),
            
            highLabel.topAnchor.constraint(equalTo: closeLabel.bottomAnchor, constant: Constants.labelVerticalInset),
            highLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            highLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            highLabel.widthAnchor.constraint(equalToConstant: Constants.infoLabelWidth),
            
            lowLabel.topAnchor.constraint(equalTo: highLabel.bottomAnchor, constant: Constants.labelVerticalInset),
            lowLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            lowLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            lowLabel.widthAnchor.constraint(equalToConstant: Constants.infoLabelWidth),
            
            recommendationView.topAnchor.constraint(equalTo: lowLabel.bottomAnchor, constant: Constants.recommendationTopInset),
            recommendationView.heightAnchor.constraint(equalToConstant: Constants.recommendationHeight),
            recommendationView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.viewLeadingInset),
            recommendationView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.viewLeadingInset),
            
            recommendationAccentView.leadingAnchor.constraint(
                equalTo: recommendationView.leadingAnchor,
                constant: Constants.recommendationHorizontalInset
            ),
            recommendationAccentView.centerYAnchor.constraint(equalTo: recommendationView.centerYAnchor),
            recommendationAccentView.widthAnchor.constraint(equalToConstant: Constants.recommendationAccentSize),
            recommendationAccentView.heightAnchor.constraint(equalToConstant: Constants.recommendationAccentSize),
            
            recommendationLabel.leadingAnchor.constraint(
                equalTo: recommendationAccentView.trailingAnchor,
                constant: Constants.recommendationTextSpacing
            ),
            recommendationLabel.trailingAnchor.constraint(
                equalTo: recommendationView.trailingAnchor,
                constant: -Constants.recommendationHorizontalInset
            ),
            recommendationLabel.centerYAnchor.constraint(equalTo: recommendationView.centerYAnchor),
            
            candlesChartView.topAnchor.constraint(equalTo: recommendationView.bottomAnchor, constant: Constants.collectionViewTopInset),
            candlesChartView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            candlesChartView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            candlesChartView.heightAnchor.constraint(equalToConstant: Constants.collectionViewHeight),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: candlesChartView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: candlesChartView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: candlesChartView.leadingAnchor, constant: Constants.horizontalInset),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: candlesChartView.trailingAnchor, constant: -Constants.horizontalInset),
            
            segmentedControl.topAnchor.constraint(equalTo: candlesChartView.bottomAnchor, constant: Constants.segmentedControlVerticalInset),
            segmentedControl.heightAnchor.constraint(equalToConstant: Constants.segmentedControlHeight),
            segmentedControl.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            
            linesChartView.topAnchor.constraint(equalTo: recommendationView.bottomAnchor, constant: Constants.collectionViewTopInset),
            linesChartView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            linesChartView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            linesChartView.heightAnchor.constraint(equalToConstant: Constants.collectionViewHeight)
        ])
    }
}

// MARK: - View State
private extension GraphViewController {
    func render(_ state: GraphViewModel.ViewState) {
        candlesChartView.isHidden = state.activeMode == .line
        linesChartView.isHidden = state.activeMode == .candlestick
        emptyStateLabel.isHidden = !state.isEmpty
        infoLabel.text = state.infoText
        openLabel.text = state.openText
        closeLabel.text = state.closeText
        highLabel.text = state.highText
        lowLabel.text = state.lowText
        recommendationLabel.attributedText = makeRecommendationText(from: state)
        applyRecommendationAppearance(for: state.recommendationTone)
    }

    func applyRecommendationAppearance(for tone: RecommendationTone) {
        let appearance = makeRecommendationAppearance(for: tone)
        recommendationView.backgroundColor = appearance.backgroundColor
        recommendationView.layer.borderColor = appearance.borderColor
        recommendationAccentView.backgroundColor = appearance.accentColor
    }
    
    func makeRecommendationText(from state: GraphViewModel.ViewState) -> NSAttributedString {
        let appearance = makeRecommendationAppearance(for: state.recommendationTone)
        let text = state.recommendationText
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                .foregroundColor: appearance.textColor,
                .font: UIFont.systemFont(
                    ofSize: Constants.recommendationFontSize,
                    weight: .medium
                )
            ]
        )
        let recommendationRange = (text as NSString).range(of: Constants.recommendationTextPrefix)
        
        guard recommendationRange.location != NSNotFound else {
            return attributedText
        }
        
        let actionRange = NSRange(
            location: recommendationRange.upperBound,
            length: text.count - recommendationRange.upperBound
        )
        attributedText.addAttributes(
            [
                .foregroundColor: appearance.accentColor,
                .font: UIFont.systemFont(
                    ofSize: Constants.recommendationFontSize,
                    weight: .semibold
                )
            ],
            range: actionRange
        )
        
        return attributedText
    }
    
    func makeRecommendationAppearance(for tone: RecommendationTone) -> RecommendationAppearance {
        switch tone {
        case .neutral:
            return RecommendationAppearance(
                backgroundColor: Constants.neutralRecommendationBackgroundColor,
                borderColor: Constants.neutralRecommendationBorderColor,
                accentColor: Constants.neutralRecommendationAccentColor,
                textColor: Constants.neutralRecommendationTextColor
            )
        case .buy:
            return RecommendationAppearance(
                backgroundColor: Constants.buyRecommendationBackgroundColor,
                borderColor: Constants.buyRecommendationBorderColor,
                accentColor: Constants.buyRecommendationAccentColor,
                textColor: Constants.buyRecommendationTextColor
            )
        case .sell:
            return RecommendationAppearance(
                backgroundColor: Constants.sellRecommendationBackgroundColor,
                borderColor: Constants.sellRecommendationBorderColor,
                accentColor: Constants.sellRecommendationAccentColor,
                textColor: Constants.sellRecommendationTextColor
            )
        case .ignore:
            return RecommendationAppearance(
                backgroundColor: Constants.ignoreRecommendationBackgroundColor,
                borderColor: Constants.ignoreRecommendationBorderColor,
                accentColor: Constants.ignoreRecommendationAccentColor,
                textColor: Constants.ignoreRecommendationTextColor
            )
        }
    }
}

// MARK: - Models
private extension GraphViewController {
    struct RecommendationAppearance {
        let backgroundColor: UIColor
        let borderColor: CGColor
        let accentColor: UIColor
        let textColor: UIColor
    }
}

// MARK: - CandlestickSelectedProtocol
extension GraphViewController: CandlestickSelectedProtocol {
    func didTappedCandle(at index: Int) {
        viewModel.handleSelection(at: index)
        render(viewModel.viewState)
    }
}

// MARK: - PointSelectedProtocol
extension GraphViewController: PointSelectedProtocol {
    func didTappedPoint(at index: Int) {
        viewModel.handleSelection(at: index)
        render(viewModel.viewState)
    }
}

// MARK: - Constants
private extension GraphViewController {
    enum Constants {
        static let emptyStateText = "No graph data yet"
        static let recommendationTextPrefix = "Recommendation: "
        static let backgroundColor: UIColor = .white
        static let neutralRecommendationBackgroundColor = UIColor(red: 0.96, green: 0.95, blue: 1.00, alpha: 1)
        static let buyRecommendationBackgroundColor = UIColor(red: 0.93, green: 1.00, blue: 0.96, alpha: 1)
        static let sellRecommendationBackgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.98, alpha: 1)
        static let ignoreRecommendationBackgroundColor = UIColor(red: 1.00, green: 0.99, blue: 0.90, alpha: 1)
        static let neutralRecommendationBorderColor = UIColor(red: 0.88, green: 0.86, blue: 0.95, alpha: 1).cgColor
        static let buyRecommendationBorderColor = UIColor(red: 0.78, green: 0.94, blue: 0.84, alpha: 1).cgColor
        static let sellRecommendationBorderColor = UIColor(red: 0.96, green: 0.80, blue: 0.86, alpha: 1).cgColor
        static let ignoreRecommendationBorderColor = UIColor(red: 0.96, green: 0.89, blue: 0.54, alpha: 1).cgColor
        static let neutralRecommendationAccentColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let buyRecommendationAccentColor = UIColor(red: 0.08, green: 0.58, blue: 0.28, alpha: 1)
        static let sellRecommendationAccentColor = UIColor(red: 0.86, green: 0.15, blue: 0.26, alpha: 1)
        static let ignoreRecommendationAccentColor = UIColor(red: 0.88, green: 0.62, blue: 0.00, alpha: 1)
        static let neutralRecommendationTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let buyRecommendationTextColor = UIColor(red: 0.12, green: 0.30, blue: 0.18, alpha: 1)
        static let sellRecommendationTextColor = UIColor(red: 0.39, green: 0.12, blue: 0.18, alpha: 1)
        static let ignoreRecommendationTextColor = UIColor(red: 0.37, green: 0.29, blue: 0.06, alpha: 1)
        static let horizontalInset: CGFloat = 16
        static let collectionViewHeight: CGFloat = 260
        static let labelHeight: CGFloat = 15
        static let infoLabelWidth: CGFloat = 235
        static let labelVerticalInset: CGFloat = 3
        static let infoViewTopInset: CGFloat = 3
        static let collectionViewTopInset: CGFloat = 10
        static let viewLeadingInset: CGFloat = 20
        static let labelsFontSize: CGFloat = 12
        static let recommendationTopInset: CGFloat = 8
        static let recommendationHeight: CGFloat = 34
        static let recommendationCornerRadius: CGFloat = 10
        static let recommendationBorderWidth: CGFloat = 1
        static let recommendationHorizontalInset: CGFloat = 12
        static let recommendationTextSpacing: CGFloat = 8
        static let recommendationAccentSize: CGFloat = 10
        static let recommendationFontSize: CGFloat = 13
        static let cornerRadiusDivisor: CGFloat = 2
        static let itemsInSegmentedControl: [String] = ["Lines", "Candlestick"]
        static let segmentedControlVerticalInset: CGFloat = 10
        static let segmentedControlHeight: CGFloat = 15
    }
}
