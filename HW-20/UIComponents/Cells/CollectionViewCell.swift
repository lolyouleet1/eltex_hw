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
        currencyLabel.transform = .identity
        currencyLabel.textColor = Constants.defaultTextColor
        starLabel.textColor = Constants.starTextColor
        starLabel.text = Constants.defaultStarSymbol
        contentView.backgroundColor = Constants.defaultBackgroundColor
        contentView.layer.borderWidth = Constants.defaultBorderWidth
        contentView.layer.borderColor = nil
        contentView.layer.cornerRadius = Constants.defaultCornerRadius
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
    
    func configureCompact(with viewModel: CurrencyItemViewModel) {
        currencyLabel.text = viewModel.title
        starLabel.text = viewModel.isFavorite
            ? Constants.favoriteStarSymbol
            : Constants.defaultStarSymbol
        
        contentView.layer.cornerRadius = Constants.compactCornerRadius
        contentView.layer.borderWidth = Constants.compactBorderWidth
        contentView.layer.borderColor = Constants.compactBorderColor
        
        currencyLabel.transform = .identity
        
        switch viewModel.selectionState {
        case .none:
            contentView.backgroundColor = Constants.compactDefaultBackgroundColor
            currencyLabel.textColor = Constants.compactDefaultTextColor
            starLabel.textColor = Constants.compactDefaultTextColor
        case .left:
            contentView.backgroundColor = Constants.compactLeftSelectionColor
            currencyLabel.textColor = Constants.compactSelectedTextColor
            starLabel.textColor = Constants.compactSelectedTextColor
        case .right:
            contentView.backgroundColor = Constants.compactRightSelectionColor
            currencyLabel.textColor = Constants.compactSelectedTextColor
            starLabel.textColor = Constants.compactSelectedTextColor
        }
    }
    
    func animateSelection() {
        currencyLabel.transform = .identity

        UIView.animate(withDuration: Constants.animationDuration) {
            self.currencyLabel.transform = CGAffineTransform(scaleX: Constants.AffineTransformScale, y: Constants.AffineTransformScale)
            self.contentView.backgroundColor = Constants.compactRightSelectionColor
        }
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
        static let defaultTextColor: UIColor = .black
        static let starTextColor: UIColor = .black
        static let defaultBackgroundColor: UIColor = .clear
        static let defaultSelectionColor: UIColor = .green
        static let selectedCurrencyColor: UIColor = .gray
        static let compactDefaultBackgroundColor: UIColor = .white
        static let compactDefaultTextColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let compactSelectedTextColor: UIColor = .white
        static let compactLeftSelectionColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let compactRightSelectionColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let compactBorderColor = UIColor(red: 0.88, green: 0.86, blue: 0.95, alpha: 1).cgColor
        static let defaultBorderWidth: CGFloat = .zero
        static let compactBorderWidth: CGFloat = 1
        static let defaultCornerRadius: CGFloat = .zero
        static let compactCornerRadius: CGFloat = 4
        static let starLabelTopSpacing: CGFloat = 4
        static let starLabelTrailingSpacing: CGFloat = -4
        static let AffineTransformScale: CGFloat = 1.6
        static let animationDuration: CGFloat = 0.3
    }
}
