import UIKit

enum OperationType {
    case buy, sell, ignore
}

struct Operation {
    let id: UUID
    let text: String
    let operationType: OperationType
}

final class TableViewCell: UITableViewCell {
    private let operationLabel = UILabel()
    private let additionalView = UIView()
    private var additionalViewHeightConstraint: NSLayoutConstraint!
    private var operationLabelHeightConstraint: NSLayoutConstraint!
    
    var currentOperation: Operation? {
        didSet {
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        addSubview()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        currentOperation = nil
        operationLabel.text = nil
        operationLabel.backgroundColor = .clear
        operationLabelHeightConstraint.constant = 0
        additionalViewHeightConstraint.constant = 0
        additionalView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods
private extension TableViewCell {
    func updateUI() {
        guard let currentOperation else { return }
        operationLabel.text = currentOperation.text

        switch currentOperation.operationType {
        case .buy:
            operationLabel.backgroundColor = .green
            operationLabelHeightConstraint.constant = 42
            additionalView.backgroundColor = .green
            additionalViewHeightConstraint.constant = 16
            
        case .sell:
            operationLabel.backgroundColor = .red
            operationLabelHeightConstraint.constant = 42
            additionalView.backgroundColor = .red
            additionalViewHeightConstraint.constant = 16
            
        case .ignore:
            operationLabel.backgroundColor = .yellow
            operationLabelHeightConstraint.constant = 30
            additionalViewHeightConstraint.constant = 0
        }
    }
    
    func setupUI() {
        operationLabel.textColor = .black
        operationLabel.numberOfLines = .zero
        operationLabel.font = .systemFont(ofSize: 14)
        
        additionalView.backgroundColor = .clear
    }
    
    func addSubview() {
        contentView.addSubview(operationLabel)
        contentView.addSubview(additionalView)
    }
    
    func setupConstraints() {
        operationLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalView.translatesAutoresizingMaskIntoConstraints = false
        
        additionalViewHeightConstraint = additionalView.heightAnchor.constraint(equalToConstant: 0)
        operationLabelHeightConstraint = operationLabel.heightAnchor.constraint(equalToConstant: 0)
        
        operationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        operationLabelHeightConstraint.isActive = true
        operationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        operationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        
        additionalView.topAnchor.constraint(equalTo: operationLabel.bottomAnchor, constant: 0).isActive = true
        additionalViewHeightConstraint.isActive = true
        additionalView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        additionalView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        additionalView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
    }
}

// MARK: - Identifier
extension TableViewCell {
    static let identifier = "TableViewCell"
}
