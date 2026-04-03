import UIKit

enum SelectedSide {
    case none
    case left
    case right
}

final class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CollectionViewCell"
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
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
        currencyLabel.text = nil
        contentView.backgroundColor = .clear
    }
    
    func configure(with currency: CurrencyCell) {
        currencyLabel.text = currency.label
        
        switch currency.selectedSide {
        case .none:
            contentView.backgroundColor = currency.colorIfNotSelected
        case .left, .right:
            contentView.backgroundColor = currency.colorIfSelected
        }
    }
}

// MARK: - Private Methods
private extension CollectionViewCell {
    func setupHierarchy() {
        contentView.addSubview(currencyLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            currencyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
