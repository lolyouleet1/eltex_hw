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
        
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: - Public Methods
    func configure(with viewModel: GraphCandlestickItemViewModel) {
        let color = makeColor(for: viewModel)
        
        bodyView.backgroundColor = color
        tailView.backgroundColor = color
        tailHeightConstraint.constant = viewModel.tailHeight
        bodyHeightConstraint.constant = viewModel.bodyHeight
        bodyCenterYConstraint.constant = viewModel.verticalOffset
        tailCenterYConstraint.constant = viewModel.verticalOffset
    }
    
    func reset() {
        bodyView.backgroundColor = Constants.clearColor
        tailView.backgroundColor = Constants.clearColor
        bodyCenterYConstraint.constant = .zero
        tailCenterYConstraint.constant = .zero
    }
}

// MARK: - Private Methods
private extension CandlestickView {
    func makeColor(for viewModel: GraphCandlestickItemViewModel) -> UIColor {
        viewModel.isGrowing ? Constants.growingColor : Constants.fallingColor
    }
    
    func setupHierarchy() {
        addSubview(tailView)
        addSubview(bodyView)
    }
    
    func setupConstraints() {
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        tailView.translatesAutoresizingMaskIntoConstraints = false
        
        tailHeightConstraint = tailView.heightAnchor.constraint(equalToConstant: Constants.initialTailHeight)
        bodyHeightConstraint = bodyView.heightAnchor.constraint(equalToConstant: Constants.initialBodyHeight)
        bodyCenterYConstraint = bodyView.centerYAnchor.constraint(equalTo: centerYAnchor)
        tailCenterYConstraint = tailView.centerYAnchor.constraint(equalTo: centerYAnchor)
        
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
        static let clearColor: UIColor = .clear
        static let growingColor: UIColor = .systemGreen
        static let fallingColor: UIColor = .systemRed
        static let tailWidth: CGFloat = 3
        static let bodyWidth: CGFloat = 20
        static let initialTailHeight: CGFloat = 100
        static let initialBodyHeight: CGFloat = 60
    }
}
