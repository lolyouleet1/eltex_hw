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
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        candlestickView.reset()
    }
    
    // MARK: - Public Methods
    func configure(with candlestick: Candlestick) {
        candlestickView.configure(with: candlestick)
    }
}

// MARK: - Setup
private extension GraphCell {
    func setupHierarchy() {
        contentView.addSubview(candlestickView)
    }
}

// MARK: - Constraints
private extension GraphCell {
    func setupConstraints() {
        candlestickView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            candlestickView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            candlestickView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            candlestickView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            candlestickView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
}
