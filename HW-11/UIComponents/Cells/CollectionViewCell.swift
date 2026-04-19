import UIKit

protocol CollectionViewCellDelegate: AnyObject {
    func didFavoriteTapped(in cell: CollectionViewCell)
}

final class CollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "CollectionViewCell"
    
    weak var delegate: CollectionViewCellDelegate?
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.labelFontSize)
        return label
    }()
    
    private let starLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.defaultStarSymbol
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: Constants.labelFontSize)
        label.textColor = Constants.starTextColor
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupHierarchy()
        setupConstraints()
        setupStarLabelGesture()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currencyLabel.text = nil
        contentView.backgroundColor = Constants.defaultBackgroundColor
        starLabel.text = Constants.defaultStarSymbol
    }
    
    // MARK: - Public Methods
    func configure(with viewModel: CurrencyItemViewModel) {
        currencyLabel.text = viewModel.title
        
        switch viewModel.selectionState {
        case .none:
            contentView.backgroundColor = Constants.defaultSelectionColor
        case .left, .right:
            contentView.backgroundColor = Constants.selectedCurrencyColor
        }
        
        starLabel.text = viewModel.isFavorite
            ? Constants.favoriteStarSymbol
            : Constants.defaultStarSymbol
    }
}

// MARK: - Setup
private extension CollectionViewCell {
    func setupHierarchy() {
        contentView.addSubview(currencyLabel)
        contentView.addSubview(starLabel)
    }
    
    func setupStarLabelGesture() {
        let starTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleStarLabelTapped)
        )
        starLabel.addGestureRecognizer(starTapGesture)
    }
    
    @objc func handleStarLabelTapped() {
        delegate?.didFavoriteTapped(in: self)
    }
}

// MARK: - Constraints
private extension CollectionViewCell {
    func setupConstraints() {
        NSLayoutConstraint.activate([
            currencyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            currencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            starLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: Constants.starLabelTrailingSpacing
            ),
            starLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constants.starLabelTopSpacing
            )
        ])
    }
}

// MARK: - Constants
private extension CollectionViewCell {
    enum Constants {
        static let labelFontSize: CGFloat = 12
        static let favoriteStarSymbol = "★"
        static let defaultStarSymbol = "☆"
        static let starTextColor: UIColor = .black
        static let defaultBackgroundColor: UIColor = .clear
        static let defaultSelectionColor: UIColor = .green
        static let selectedCurrencyColor: UIColor = .gray
        static let starLabelTopSpacing: CGFloat = 4
        static let starLabelTrailingSpacing: CGFloat = -4
    }
}
