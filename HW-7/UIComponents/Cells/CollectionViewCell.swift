import UIKit

struct CurrencyCell {
    var label: String
    var colorIfNotSelected: UIColor
    var colorIfSelected: UIColor
    var selectedSide: SelectedSide
    var exchangeRate: Float
}

enum SelectedSide {
    case none
    case left
    case right
}

class CollectionViewCell: UICollectionViewCell {
    private let currencyLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currencyLabel.text = nil
        currencyLabel.backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func configure(_ data: CurrencyCell) {
        currencyLabel.text = data.label
        switch data.selectedSide {
        case .none:
            contentView.backgroundColor = data.colorIfNotSelected
        case .left:
            contentView.backgroundColor = data.colorIfSelected
        case .right:
            contentView.backgroundColor = data.colorIfSelected
        }
        currencyLabel.font =  UIFont.systemFont(ofSize: 12)
    }
}

// MARK: - Private Methods
private extension CollectionViewCell {
    func addSubview() {
        contentView.addSubview(currencyLabel)
    }
    
    func setupConstraints() {
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            currencyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

extension CollectionViewCell {
    static let identifier = "CollectionViewCell"
}
