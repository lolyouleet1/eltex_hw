import UIKit
import Foundation

final class CandlestickView: UIView {
    // MARK: UI
    private let body = UIView()
    private let tail = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(previousPrice: Double, currentPrice: Double) {
        if currentPrice > previousPrice {
            body.backgroundColor = .green
            tail.backgroundColor = .green
        } else {
            body.backgroundColor = .red
            tail.backgroundColor = .red
        }
    }
}

// MARK: - Setup
private extension CandlestickView {
    func setupHierarchy() {
        addSubview(body)
        addSubview(tail)
    }
}

// MARK: - Constraints
private extension CandlestickView {
    func setupConstraints() {
        body.translatesAutoresizingMaskIntoConstraints = false
        tail.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            body.heightAnchor.constraint(equalToConstant: 60),
            body.widthAnchor.constraint(equalToConstant: 25),
            
            tail.heightAnchor.constraint(equalToConstant: 80),
            tail.widthAnchor.constraint(equalToConstant: 7),
            tail.centerXAnchor.constraint(equalTo: body.centerXAnchor),
            tail.centerYAnchor.constraint(equalTo: body.centerYAnchor)
        ])
    }
}
