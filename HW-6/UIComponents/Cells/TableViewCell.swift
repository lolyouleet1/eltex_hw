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
    }
    
    func addSubview() {
        contentView.addSubview(operationLabel)
    }
    
    func setupConstraints() {
        operationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        operationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        operationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        operationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).isActive = true
        operationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
    }
}

// MARK: - Identifier
extension TableViewCell {
    static let identifier = "TableViewCell"
}
