import UIKit

final class TableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "TableViewCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let accentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let operationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = Constants.multilineLineCount
        label.font = .systemFont(ofSize: Constants.labelFontSize)
        return label
    }()
    
    private var containerHeightConstraint: NSLayoutConstraint!
    
    var currentOperation: OperationCellViewModel? {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentOperation = nil
        resetAppearance()
    }
}

// MARK: - Setup
private extension TableViewCell {
    func setupView() {
        selectionStyle = .none
        backgroundColor = Constants.clearColor
        contentView.backgroundColor = Constants.clearColor
    }
    
    func setupHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubview(operationLabel)
        containerView.addSubview(accentView)
    }
}

// MARK: - Private Methods
private extension TableViewCell {
    func updateAppearance() {
        guard let operation = currentOperation else { return }
        
        let appearance = makeAppearance(for: operation.operationType)
        operationLabel.text = operation.text
        operationLabel.textColor = appearance.textColor
        containerView.backgroundColor = appearance.backgroundColor
        accentView.backgroundColor = appearance.accentColor
        containerHeightConstraint.constant = appearance.height
    }
    
    func resetAppearance() {
        operationLabel.text = nil
        operationLabel.textColor = Constants.primaryTextColor
        containerView.backgroundColor = Constants.clearColor
        accentView.backgroundColor = Constants.clearColor
        containerHeightConstraint.constant = Constants.zeroHeight
    }
    
    func makeAppearance(for operationType: OperationType) -> OperationAppearance {
        switch operationType {
        case .buy:
            return OperationAppearance(
                backgroundColor: Constants.buyBackgroundColor,
                accentColor: Constants.buyAccentColor,
                textColor: Constants.primaryTextColor,
                height: Constants.defaultRowHeight
            )
        case .sell:
            return OperationAppearance(
                backgroundColor: Constants.sellBackgroundColor,
                accentColor: Constants.sellAccentColor,
                textColor: Constants.sellTextColor,
                height: Constants.largeRowHeight
            )
        case .ignore:
            return OperationAppearance(
                backgroundColor: Constants.ignoreBackgroundColor,
                accentColor: Constants.ignoreAccentColor,
                textColor: Constants.primaryTextColor,
                height: Constants.defaultRowHeight
            )
        }
    }
}

// MARK: - Constraints
private extension TableViewCell {
    func setupConstraints() {
        containerHeightConstraint = containerView.heightAnchor.constraint(
            equalToConstant: Constants.zeroHeight
        )
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerHeightConstraint,
            
            accentView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.accentLeadingInset
            ),
            accentView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.accentVerticalInset
            ),
            accentView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor,
                constant: -Constants.accentVerticalInset
            ),
            accentView.widthAnchor.constraint(equalToConstant: Constants.accentWidth),
            
            operationLabel.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.labelLeadingInset
            ),
            operationLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Constants.labelTrailingInset
            ),
            operationLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}

// MARK: - Models
private extension TableViewCell {
    struct OperationAppearance {
        let backgroundColor: UIColor
        let accentColor: UIColor
        let textColor: UIColor
        let height: CGFloat
    }
}

// MARK: - Constants
private extension TableViewCell {
    enum Constants {
        static let multilineLineCount = 0
        static let primaryTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let sellTextColor = UIColor(red: 0.86, green: 0.15, blue: 0.26, alpha: 1)
        static let buyAccentColor = UIColor(red: 0.08, green: 0.78, blue: 0.40, alpha: 1)
        static let sellAccentColor = UIColor(red: 1.00, green: 0.14, blue: 0.32, alpha: 1)
        static let ignoreAccentColor = UIColor(red: 1.00, green: 0.80, blue: 0.03, alpha: 1)
        static let buyBackgroundColor: UIColor = UIColor(red: 0.93, green: 1.00, blue: 0.96, alpha: 1)
        static let sellBackgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.98, alpha: 1)
        static let ignoreBackgroundColor = UIColor(red: 1.00, green: 0.99, blue: 0.90, alpha: 1)
        static let clearColor: UIColor = .clear
        static let labelFontSize: CGFloat = 15
        static let defaultRowHeight: CGFloat = 52
        static let largeRowHeight: CGFloat = 62
        static let zeroHeight: CGFloat = .zero
        static let labelLeadingInset: CGFloat = 28
        static let labelTrailingInset: CGFloat = 16
        static let accentLeadingInset: CGFloat = 6
        static let accentVerticalInset: CGFloat = 8
        static let accentWidth: CGFloat = 3
    }
}
