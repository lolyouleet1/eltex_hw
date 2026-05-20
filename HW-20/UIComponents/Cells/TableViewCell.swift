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
    
    var currentResult: BotResultCellViewModel? {
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
        
        currentResult = nil
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
        guard let result = currentResult else { return }
        
        let appearance = makeAppearance(for: result.tone)
        operationLabel.text = result.text
        operationLabel.textColor = appearance.textColor
        containerView.backgroundColor = appearance.backgroundColor
        accentView.backgroundColor = appearance.accentColor
        containerHeightConstraint.constant = Constants.rowHeight
    }
    
    func resetAppearance() {
        operationLabel.text = nil
        operationLabel.textColor = Constants.primaryTextColor
        containerView.backgroundColor = Constants.clearColor
        accentView.backgroundColor = Constants.clearColor
        containerHeightConstraint.constant = Constants.zeroHeight
    }
    
    func makeAppearance(for tone: ResultTone) -> OperationAppearance {
        switch tone {
        case .neutral:
            return OperationAppearance(
                backgroundColor: Constants.neutralBackgroundColor,
                accentColor: Constants.neutralAccentColor,
                textColor: Constants.primaryTextColor
            )
        case .positive:
            return OperationAppearance(
                backgroundColor: Constants.positiveBackgroundColor,
                accentColor: Constants.positiveAccentColor,
                textColor: Constants.positiveTextColor
            )
        case .negative:
            return OperationAppearance(
                backgroundColor: Constants.negativeBackgroundColor,
                accentColor: Constants.negativeAccentColor,
                textColor: Constants.negativeTextColor
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
    }
}

// MARK: - Constants
private extension TableViewCell {
    enum Constants {
        static let multilineLineCount = 0
        static let primaryTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let positiveTextColor = UIColor(red: 0.08, green: 0.58, blue: 0.28, alpha: 1)
        static let negativeTextColor = UIColor(red: 0.86, green: 0.15, blue: 0.26, alpha: 1)
        static let positiveAccentColor = UIColor(red: 0.08, green: 0.78, blue: 0.40, alpha: 1)
        static let negativeAccentColor = UIColor(red: 1.00, green: 0.14, blue: 0.32, alpha: 1)
        static let neutralAccentColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let positiveBackgroundColor: UIColor = UIColor(red: 0.93, green: 1.00, blue: 0.96, alpha: 1)
        static let negativeBackgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.98, alpha: 1)
        static let neutralBackgroundColor = UIColor(red: 0.96, green: 0.95, blue: 1.00, alpha: 1)
        static let clearColor: UIColor = .clear
        static let labelFontSize: CGFloat = 15
        static let rowHeight: CGFloat = 56
        static let zeroHeight: CGFloat = .zero
        static let labelLeadingInset: CGFloat = 28
        static let labelTrailingInset: CGFloat = 16
        static let accentLeadingInset: CGFloat = 6
        static let accentVerticalInset: CGFloat = 8
        static let accentWidth: CGFloat = 3
    }
}
