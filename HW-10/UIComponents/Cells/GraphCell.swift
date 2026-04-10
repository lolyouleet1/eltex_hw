import Foundation
import UIKit

final class GraphCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "GraphCell"
    private var candlestickView: CandlestickView
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        candlestickView = CandlestickView()
        
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with view: CandlestickView) {
        candlestickView = view
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
            candlestickView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.candlestickViewVerticalInset),
            candlestickView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.candlestickViewVerticalInset),
            candlestickView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.candlestickViewHorizontalInset),
            candlestickView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.candlestickViewHorizontalInset)
        ])
    }
}

// MARK: - Constants
private extension GraphCell {
    enum Constants {
        static let candlestickViewVerticalInset: CGFloat = 30
        static let candlestickViewHorizontalInset: CGFloat = 10
    }
}
