import UIKit

final class CandlestickView: UIView {
    // MARK: - UI
    private let bodyView = UIView()
    private let tailView = UIView()
    
    private var bodyHeightConstraint: NSLayoutConstraint!
    private var tailHeightConstraint: NSLayoutConstraint!
    private var bodyCenterYConstraint: NSLayoutConstraint!
    private var tailCenterYConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = true
        
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with candlestick: Candlestick) {
        let color: UIColor = candlestick.isGrowing ? .systemGreen : .systemRed
        
        bodyView.backgroundColor = color
        tailView.backgroundColor = color
        
        let totalRange = max(candlestick.high - candlestick.low, Constants.minTotalRange)
        let bodyRange = max(abs(candlestick.close - candlestick.open), Constants.minBodyRange)
        
        tailHeightConstraint.constant = Constants.maxTailHeight
        bodyHeightConstraint.constant = max(
            Constants.minBodyHeight,
            CGFloat(bodyRange / totalRange) * Constants.maxTailHeight
        )
        
        bodyCenterYConstraint.constant = candlestick.verticalOffset
        tailCenterYConstraint.constant = candlestick.verticalOffset
    }
    
    func reset() {
        bodyView.backgroundColor = .clear
        tailView.backgroundColor = .clear
        bodyCenterYConstraint.constant = .zero
        tailCenterYConstraint.constant = .zero
    }
}

// MARK: - Setup
private extension CandlestickView {
    func setupHierarchy() {
        addSubview(tailView)
        addSubview(bodyView)
    }
    
    func setupConstraints() {
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        tailView.translatesAutoresizingMaskIntoConstraints = false
        
        tailHeightConstraint = tailView.heightAnchor.constraint(equalToConstant: Constants.initialTailHeight)
        bodyHeightConstraint = bodyView.heightAnchor.constraint(equalToConstant: Constants.initialBodyHeight)
        
        tailCenterYConstraint = tailView.centerYAnchor.constraint(equalTo: centerYAnchor)
        bodyCenterYConstraint = bodyView.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        NSLayoutConstraint.activate([
            tailView.centerXAnchor.constraint(equalTo: centerXAnchor),
            tailCenterYConstraint,
            tailView.widthAnchor.constraint(equalToConstant: Constants.tailWidth),
            tailHeightConstraint,
            
            bodyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bodyCenterYConstraint,
            bodyView.widthAnchor.constraint(equalToConstant: Constants.bodyWidth),
            bodyHeightConstraint
        ])
    }
}

// MARK: - Constants
private extension CandlestickView {
    enum Constants {
        static let minTotalRange: Double = 1
        static let minBodyRange: Double = 1
        
        static let maxTailHeight: CGFloat = 120
        static let minBodyHeight: CGFloat = 10
        
        static let initialTailHeight: CGFloat = 120
        static let initialBodyHeight: CGFloat = 60
        
        static let tailWidth: CGFloat = 2
        static let bodyWidth: CGFloat = 12
    }
}
