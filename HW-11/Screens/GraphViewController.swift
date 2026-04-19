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
    
    private let recommendationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: Constants.labelsFontSize)
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
            
            recommendationView.topAnchor.constraint(equalTo: lowLabel.bottomAnchor, constant: Constants.labelVerticalInset),
            recommendationView.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            recommendationView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.viewLeadingInset),
            recommendationView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.viewLeadingInset),
            
            recommendationLabel.topAnchor.constraint(equalTo: recommendationView.topAnchor),
            recommendationLabel.leadingAnchor.constraint(equalTo: recommendationView.leadingAnchor),
            recommendationLabel.trailingAnchor.constraint(equalTo: recommendationView.trailingAnchor),
            recommendationLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            
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
        recommendationLabel.text = state.recommendationText
        recommendationLabel.backgroundColor = makeRecommendationColor(for: state.recommendationTone)
    }

    func makeRecommendationColor(for tone: RecommendationTone) -> UIColor {
        switch tone {
        case .neutral:
            return Constants.neutralRecommendationColor
        case .buy:
            return Constants.buyRecommendationColor
        case .sell:
            return Constants.sellRecommendationColor
        case .ignore:
            return Constants.ignoreRecommendationColor
        }
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
        static let backgroundColor: UIColor = .white
        static let neutralRecommendationColor: UIColor = .clear
        static let buyRecommendationColor: UIColor = .green
        static let sellRecommendationColor: UIColor = .red
        static let ignoreRecommendationColor: UIColor = .yellow
        static let horizontalInset: CGFloat = 16
        static let collectionViewHeight: CGFloat = 260
        static let labelHeight: CGFloat = 15
        static let infoLabelWidth: CGFloat = 235
        static let labelVerticalInset: CGFloat = 3
        static let infoViewTopInset: CGFloat = 3
        static let collectionViewTopInset: CGFloat = 10
        static let viewLeadingInset: CGFloat = 20
        static let labelsFontSize: CGFloat = 12
        static let itemsInSegmentedControl: [String] = ["Lines", "Candlestick"]
        static let segmentedControlVerticalInset: CGFloat = 10
        static let segmentedControlHeight: CGFloat = 15
    }
}
