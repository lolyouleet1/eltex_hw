import UIKit

final class TableViewCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "TableViewCell"
    
    private let operationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constants.operationTextColor
        label.numberOfLines = Constants.multilineLineCount
        label.font = .systemFont(ofSize: Constants.labelFontSize)
        return label
    }()
    
    private let additionalView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var additionalViewHeightConstraint: NSLayoutConstraint!
    private var operationLabelHeightConstraint: NSLayoutConstraint!
    
    var currentOperation: OperationCellViewModel? {
        didSet {
            updateAppearance()
        }
    }
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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

// MARK: - Private Methods
private extension TableViewCell {
    func updateAppearance() {
        guard let operation = currentOperation else { return }
        
        operationLabel.text = operation.text
        
        switch operation.operationType {
        case .buy:
            operationLabel.backgroundColor = Constants.buyColor
            operationLabelHeightConstraint.constant = Constants.buySellLabelHeight
            additionalView.backgroundColor = Constants.buyColor
            additionalViewHeightConstraint.constant = Constants.additionalViewHeight
            
        case .sell:
            operationLabel.backgroundColor = Constants.sellColor
            operationLabelHeightConstraint.constant = Constants.buySellLabelHeight
            additionalView.backgroundColor = Constants.sellColor
            additionalViewHeightConstraint.constant = Constants.additionalViewHeight
            
        case .ignore:
            operationLabel.backgroundColor = Constants.ignoreColor
            operationLabelHeightConstraint.constant = Constants.ignoreLabelHeight
            additionalView.backgroundColor = Constants.clearColor
            additionalViewHeightConstraint.constant = Constants.zeroHeight
        }
    }
    
    func resetAppearance() {
        operationLabel.text = nil
        operationLabel.backgroundColor = Constants.clearColor
        operationLabelHeightConstraint.constant = Constants.zeroHeight
        additionalView.backgroundColor = Constants.clearColor
        additionalViewHeightConstraint.constant = Constants.zeroHeight
    }
    
    func setupHierarchy() {
        contentView.addSubview(operationLabel)
        contentView.addSubview(additionalView)
    }
}

// MARK: - Constraints
private extension TableViewCell {
    func setupConstraints() {
        additionalViewHeightConstraint = additionalView.heightAnchor.constraint(
            equalToConstant: Constants.zeroHeight
        )
        operationLabelHeightConstraint = operationLabel.heightAnchor.constraint(
            equalToConstant: Constants.zeroHeight
        )
        
        NSLayoutConstraint.activate([
            operationLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            operationLabelHeightConstraint,
            operationLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.horizontalInset
            ),
            operationLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.horizontalInset
            ),
            
            additionalView.topAnchor.constraint(equalTo: operationLabel.bottomAnchor),
            additionalViewHeightConstraint,
            additionalView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            additionalView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Constants.horizontalInset
            ),
            additionalView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Constants.horizontalInset
            )
        ])
    }
}

// MARK: - Constants
private extension TableViewCell {
    enum Constants {
        static let multilineLineCount = 0
        static let operationTextColor: UIColor = .black
        static let buyColor: UIColor = .green
        static let sellColor: UIColor = .red
        static let ignoreColor: UIColor = .yellow
        static let clearColor: UIColor = .clear
        static let horizontalInset: CGFloat = 12
        static let labelFontSize: CGFloat = 14
        static let buySellLabelHeight: CGFloat = 42
        static let ignoreLabelHeight: CGFloat = 30
        static let additionalViewHeight: CGFloat = 16
        static let zeroHeight: CGFloat = .zero
    }
}
