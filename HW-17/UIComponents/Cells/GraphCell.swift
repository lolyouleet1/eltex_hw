import UIKit

final class GraphCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "GraphCell"
    
    private let candlestickView = CandlestickView()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        candlestickView.reset()
    }
    
    // MARK: - Public Methods
    func configure(with viewModel: GraphCandlestickItemViewModel) {
        candlestickView.configure(with: viewModel)
    }
}

// MARK: - Setup
private extension GraphCell {
    func setupHierarchy() {
        contentView.addSubview(candlestickView)
    }
    
    func setupConstraints() {
        candlestickView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            candlestickView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInset),
            candlestickView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalInset),
            candlestickView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            candlestickView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset)
        ])
    }
}

// MARK: - Constants
private extension GraphCell {
    enum Constants {
        static let verticalInset: CGFloat = 20
        static let horizontalInset: CGFloat = 5
    }
}
