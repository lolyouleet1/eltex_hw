import UIKit

enum OperationType {
    case buy
    case sell
    case ignore
}

struct Operation {
    let id: UUID
    let text: String
    let operationType: OperationType
}

final class TableViewCell: UITableViewCell {
    
    static let identifier = "TableViewCell"
    
    private enum Constants {
        static let horizontalInset: CGFloat = 12
        static let labelFontSize: CGFloat = 14
        static let buySellLabelHeight: CGFloat = 42
        static let ignoreLabelHeight: CGFloat = 30
        static let additionalViewHeight: CGFloat = 16
        static let zeroHeight: CGFloat = 0
    }
    
    private let operationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.numberOfLines = 0
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
    
    var currentOperation: Operation? {
        didSet {
            updateAppearance()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            operationLabel.backgroundColor = .green
            operationLabelHeightConstraint.constant = Constants.buySellLabelHeight
            additionalView.backgroundColor = .green
            additionalViewHeightConstraint.constant = Constants.additionalViewHeight
            
        case .sell:
            operationLabel.backgroundColor = .red
            operationLabelHeightConstraint.constant = Constants.buySellLabelHeight
            additionalView.backgroundColor = .red
            additionalViewHeightConstraint.constant = Constants.additionalViewHeight
            
        case .ignore:
            operationLabel.backgroundColor = .yellow
            operationLabelHeightConstraint.constant = Constants.ignoreLabelHeight
            additionalView.backgroundColor = .clear
            additionalViewHeightConstraint.constant = Constants.zeroHeight
        }
    }
    
    func resetAppearance() {
        operationLabel.text = nil
        operationLabel.backgroundColor = .clear
        operationLabelHeightConstraint.constant = Constants.zeroHeight
        additionalView.backgroundColor = .clear
        additionalViewHeightConstraint.constant = Constants.zeroHeight
    }
    
    func setupViews() {
        additionalView.backgroundColor = .clear
    }
    
    func setupHierarchy() {
        contentView.addSubview(operationLabel)
        contentView.addSubview(additionalView)
    }
    
    func setupConstraints() {
        additionalViewHeightConstraint = additionalView.heightAnchor.constraint(equalToConstant: Constants.zeroHeight)
        operationLabelHeightConstraint = operationLabel.heightAnchor.constraint(equalToConstant: Constants.zeroHeight)
        
        NSLayoutConstraint.activate([
            operationLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            operationLabelHeightConstraint,
            operationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            operationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            
            additionalView.topAnchor.constraint(equalTo: operationLabel.bottomAnchor),
            additionalViewHeightConstraint,
            additionalView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            additionalView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            additionalView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset)
        ])
    }
}
