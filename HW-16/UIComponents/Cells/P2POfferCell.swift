import UIKit

final class P2POfferCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "P2POfferCell"
    
    // MARK: - UI
    private let containerView = UIView()
    private let sellerLabel = UILabel()
    private let rateLabel = UILabel()
    private let reserveLabel = UILabel()
    private let labelsStackView = UIStackView()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupLabels()
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        sellerLabel.text = nil
        rateLabel.text = nil
        reserveLabel.text = nil
    }
    
    // MARK: - Public Methods
    func configure(with viewModel: P2POfferCellViewModel) {
        sellerLabel.text = viewModel.sellerText
        rateLabel.text = viewModel.rateText
        reserveLabel.text = viewModel.reserveText
    }
}

// MARK: - Setup
private extension P2POfferCell {
    func setupView() {
        selectionStyle = .none
        backgroundColor = Constants.clearColor
        contentView.backgroundColor = Constants.clearColor
        
        containerView.backgroundColor = Constants.containerColor
        containerView.layer.cornerRadius = Constants.containerCornerRadius
        containerView.layer.borderWidth = Constants.containerBorderWidth
        containerView.layer.borderColor = Constants.containerBorderColor
        containerView.clipsToBounds = true
    }
    
    func setupLabels() {
        sellerLabel.font = .systemFont(ofSize: Constants.sellerFontSize, weight: .semibold)
        sellerLabel.textColor = Constants.primaryTextColor
        
        rateLabel.font = .systemFont(ofSize: Constants.detailFontSize, weight: .medium)
        rateLabel.textColor = Constants.positiveTextColor
        
        reserveLabel.font = .systemFont(ofSize: Constants.detailFontSize)
        reserveLabel.textColor = Constants.secondaryTextColor
        
        labelsStackView.axis = .vertical
        labelsStackView.spacing = Constants.stackSpacing
    }
    
    func setupHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(labelsStackView)
        
        labelsStackView.addArrangedSubview(sellerLabel)
        labelsStackView.addArrangedSubview(rateLabel)
        labelsStackView.addArrangedSubview(reserveLabel)
    }
}

// MARK: - Constraints
private extension P2POfferCell {
    func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInset),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalInset),
            
            labelsStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.contentInset),
            labelsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.contentInset),
            labelsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.contentInset),
            labelsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constants.contentInset)
        ])
    }
}

// MARK: - Constants
private extension P2POfferCell {
    enum Constants {
        static let clearColor: UIColor = .clear
        static let containerColor: UIColor = .white
        static let primaryTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let secondaryTextColor = UIColor(red: 0.39, green: 0.40, blue: 0.58, alpha: 1)
        static let positiveTextColor = UIColor(red: 0.08, green: 0.58, blue: 0.28, alpha: 1)
        static let containerBorderColor = UIColor(red: 0.88, green: 0.86, blue: 0.95, alpha: 1).cgColor
        static let sellerFontSize: CGFloat = 17
        static let detailFontSize: CGFloat = 14
        static let stackSpacing: CGFloat = 6
        static let verticalInset: CGFloat = 6
        static let horizontalInset: CGFloat = 16
        static let contentInset: CGFloat = 14
        static let containerCornerRadius: CGFloat = 6
        static let containerBorderWidth: CGFloat = 1
    }
}
