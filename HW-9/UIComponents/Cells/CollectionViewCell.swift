import UIKit

protocol CollectionViewCellDelegate: AnyObject {
    func didFavoriteTapped(in cell: CollectionViewCell)
}

final class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = "CollectionViewCell"
    
    weak var delegate: CollectionViewCellDelegate?
    
    // MARK: - Constants
    private enum Constants {
        static let starLabelTopSpacing: CGFloat = 4
        static let starLabelTrailingSpacing: CGFloat = -4
    }
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    private let starLabel: UILabel = {
        let label = UILabel()
        label.text = "☆"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.isUserInteractionEnabled = true
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
        setupStarLabelGesture()
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
        
        starLabel.text = currency.isFavorite ? "★" : "☆"
    }
}

// MARK: - Private Methods
private extension CollectionViewCell {
    func setupHierarchy() {
        contentView.addSubview(currencyLabel)
        contentView.addSubview(starLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            currencyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            starLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.starLabelTrailingSpacing),
            starLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.starLabelTopSpacing)
        ])
    }
    
    func setupStarLabelGesture() {
        let starTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleStarLabelTapped))
        starLabel.addGestureRecognizer(starTapGesture)
    }
    
    @objc func handleStarLabelTapped() {
        delegate?.didFavoriteTapped(in: self)
    }
}
