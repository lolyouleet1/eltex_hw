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
        } else if currentOperation.operationType == 2 {
            operationLabel.backgroundColor = .red
        } else {
            operationLabel.backgroundColor = .yellow
        }
        
    }
    
    func setupUI() {
        operationLabel.textColor = .black
        operationLabel.numberOfLines = .zero
        operationLabel.font = .systemFont(ofSize: 12)
        
        additionalView.backgroundColor = .purple
    }
    
    func addSubview() {
        contentView.addSubview(operationLabel)
        contentView.addSubview(additionalView)
    }
    
    func setupConstraints() {
        operationLabel.translatesAutoresizingMaskIntoConstraints = false
        additionalView.translatesAutoresizingMaskIntoConstraints = false
        
        operationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        operationLabel.heightAnchor.constraint(equalToConstant: 42).isActive = true
        operationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        operationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        
        additionalView.topAnchor.constraint(equalTo: operationLabel.bottomAnchor, constant: 0).isActive = true
        additionalView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        additionalView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        additionalView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
    }
}

// MARK: - Identifier
extension TableViewCell {
    static let identifier = "TableViewCell"
}
