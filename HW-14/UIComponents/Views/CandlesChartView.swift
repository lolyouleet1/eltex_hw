import UIKit

protocol CandlestickSelectedProtocol: AnyObject {
    func didTappedCandle(at indexPath: Int)
}

final class CandlesChartView: UIView {
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: Constants.itemWidth, height: Constants.itemHeight)
        layout.minimumLineSpacing = Constants.itemSpacing
        
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // MARK: - Delegate
    weak var delegate: CandlestickSelectedProtocol?
    
    // MARK: - Dependencies
    private let viewModel: GraphViewModel
    
    // MARK: - Lifecycle
    init(frame: CGRect, viewModel: GraphViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        
        setupCollectionView()
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - Private Methods
private extension CandlesChartView {
    func setupHierarchy() {
        addSubview(collectionView)
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = Constants.backgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(GraphCell.self, forCellWithReuseIdentifier: GraphCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCollectionViewTap)
        )
        collectionView.addGestureRecognizer(tapGestureRecognizer)
    }
}

// MARK: - Constraints
private extension CandlesChartView {
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

// MARK: - Actions
private extension CandlesChartView {
    @objc func handleCollectionViewTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: location) else { return }
        
        delegate?.didTappedCandle(at: indexPath.item)
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension CandlesChartView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.viewState.candlesticks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: GraphCell.identifier,
            for: indexPath
        ) as? GraphCell else {
            return UICollectionViewCell(frame: .zero)
        }
        
        cell.configure(with: viewModel.viewState.candlesticks[indexPath.item])
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CandlesChartView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.handleSelection(at: indexPath.item)
        collectionView.reloadData()
    }
}

// MARK: - Constants
private extension CandlesChartView {
    enum Constants {
        static let backgroundColor: UIColor = .secondarySystemBackground
        static let itemWidth: CGFloat = 30
        static let itemHeight: CGFloat = 160
        static let itemSpacing: CGFloat = 2
    }
}
