import UIKit

final class GraphViewController: UIViewController {
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: Constants.itemSizeWidth, height: Constants.itemSizeHeight)
        layout.minimumLineSpacing = 0
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No graph data yet"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
            
        return label
    }()
    
    private let infoView = UIView()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose candlestick to get info"
        return label
    }()
    
    private let openLabel = UILabel()
    private let closeLabel = UILabel()
    private let highLabel = UILabel()
    private let lowLabel = UILabel()
    
    private let recommendationView = UIView()
    
    private let recommendationLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose candlestick to get recommendation"
        label.textAlignment = .center
        
        return label
    }()
    
    // MARK: - Dependencies
    private let session: TradingSession
    
    // MARK: - Lifecycle
    init(tradingSession: TradingSession) {
        self.session = tradingSession
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupHierarchy()
        setupCollectionView()
        setupInfoView()
        setupRecommendationView()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        resetInfoLabels()
        updateEmptyState()
    }
    
    func updateInfoLabels(open: Double, close: Double, high: Double, low: Double, recommendation: OperationType) {
        infoLabel.text = "INFO:"
        openLabel.text = "Open: \(open)"
        closeLabel.text = "Close: \(close)"
        highLabel.text = "High: \(high)"
        lowLabel.text = "Low: \(low)"
        
        switch recommendation {
        case .buy:
            recommendationLabel.text = "Recommendation: BUY"
            recommendationLabel.backgroundColor = .green
        case .sell:
            recommendationLabel.text = "Recommendation: SELL"
            recommendationLabel.backgroundColor = .red
        case .ignore:
            recommendationLabel.text = "Recommendation: IGNORE"
            recommendationLabel.backgroundColor = .yellow
        }
    }
}

// MARK: - Setup
private extension GraphViewController {
    func setupView() {
        view.backgroundColor = .white
    }
    
    func setupHierarchy() {
        view.addSubview(collectionView)
        view.addSubview(infoView)
        view.addSubview(recommendationView)
        view.addSubview(emptyStateLabel)
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GraphCell.self, forCellWithReuseIdentifier: GraphCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
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
}

// MARK: - Constraints
private extension GraphViewController {
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        openLabel.translatesAutoresizingMaskIntoConstraints = false
        closeLabel.translatesAutoresizingMaskIntoConstraints = false
        highLabel.translatesAutoresizingMaskIntoConstraints = false
        lowLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendationView.translatesAutoresizingMaskIntoConstraints = false
        recommendationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.graphTopInset),
            collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Constants.collectionViewHeight),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: collectionView.leadingAnchor, constant: Constants.horizontalInset),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: collectionView.trailingAnchor, constant: -Constants.horizontalInset),
            
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
            
            recommendationView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            recommendationView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.viewLeadingInset),
            recommendationView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.viewLeadingInset),
            
            recommendationLabel.topAnchor.constraint(equalTo: recommendationView.topAnchor),
            recommendationLabel.leadingAnchor.constraint(equalTo: recommendationView.leadingAnchor),
            recommendationLabel.trailingAnchor.constraint(equalTo: recommendationView.trailingAnchor),
            recommendationLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight)
        ])
    }
}

// MARK: - Private Methods
extension GraphViewController {
    func resetInfoLabels() {
        infoLabel.text = "Choose candlestick to get info"
        openLabel.text = nil
        closeLabel.text = nil
        highLabel.text = nil
        lowLabel.text = nil
            
        recommendationLabel.text = "Choose candlestick to get recommendation"
        recommendationLabel.backgroundColor = .clear
    }
    
    func updateEmptyState() {
        let isEmpty = session.candlesticks.isEmpty
            
        emptyStateLabel.isHidden = !isEmpty
        collectionView.isScrollEnabled = !isEmpty
    }
}

// MARK: - UICollectionViewDataSource
extension GraphViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        session.candlesticks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GraphCell.identifier,
            for: indexPath
        ) as? GraphCell else {
            fatalError("Could not dequeue GraphCell")
        }
        
        let candlestick = session.candlesticks[indexPath.item]
        cell.configure(with: candlestick)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GraphViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let open = (session.candlesticks[indexPath.item].open * 1000).rounded() / 1000
        let close = (session.candlesticks[indexPath.item].close * 1000).rounded() / 1000
        let high = (session.candlesticks[indexPath.item].high * 1000).rounded() / 1000
        let low = (session.candlesticks[indexPath.item].low * 1000).rounded() / 1000
        let recommendation = session.candlesticks[indexPath.item].recommendation
        
        updateInfoLabels(open: open, close: close, high: high, low: low, recommendation: recommendation)
    }
}

// MARK: - Constants
private extension GraphViewController {
    enum Constants {
        static let graphTopInset: CGFloat = 220
        static let horizontalInset: CGFloat = 16
        static let collectionViewHeight: CGFloat = 260
        static let itemSizeWidth = 20
        static let itemSizeHeight = 140
        static let labelHeight: CGFloat = 20
        static let infoLabelWidth: CGFloat = 235
        static let recommendationLabelWidth: CGFloat = 340
        static let labelVerticalInset: CGFloat = 5
        static let infoViewTopInset: CGFloat = 20
        static let viewLeadingInset: CGFloat = 20
    }
}
