//
//  TableViewCell.swift
//  HW-5
//
//  Created by Roman Prokhorov on 26.03.2026.
//

import UIKit

struct Operation {
    let id: UUID
    let text: String
    
    // MARK: - 0: Ignore, 1: Buy, 2: Sell
    let operationType: Int
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
//        additionalView.isHidden = true
        additionalViewHeightConstraint.constant = 0
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
        
        if currentOperation.operationType == 1 {
            operationLabel.backgroundColor = .green
            operationLabelHeightConstraint.constant = 42
            additionalView.backgroundColor = .green
            additionalViewHeightConstraint.constant = 16
//            additionalView.isHidden = false
        } else if currentOperation.operationType == 2 {
            operationLabel.backgroundColor = .red
            operationLabelHeightConstraint.constant = 42
            additionalView.backgroundColor = .red
            additionalViewHeightConstraint.constant = 16
//            additionalView.isHidden = false
        } else {
            operationLabel.backgroundColor = .yellow
            operationLabelHeightConstraint.constant = 30
            additionalViewHeightConstraint.constant = 0
        }
    }
    
    func setupUI() {
        operationLabel.textColor = .black
        operationLabel.numberOfLines = .zero
        operationLabel.font = .systemFont(ofSize: 12)
        
        additionalView.backgroundColor = .clear
//        additionalView.isHidden = true
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
//        operationLabel.heightAnchor.constraint(equalToConstant: 42).isActive = true
        operationLabelHeightConstraint.isActive = true
        operationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        operationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        
        additionalView.topAnchor.constraint(equalTo: operationLabel.bottomAnchor, constant: 0).isActive = true
//        additionalView.heightAnchor.constraint(equalToConstant: 16).isActive = true
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
