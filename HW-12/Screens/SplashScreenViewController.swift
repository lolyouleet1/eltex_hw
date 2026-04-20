import UIKit

protocol SplashFinishedProtocol: AnyObject {
    func splashDidFinished()
}

final class SplashScreenViewController: UIViewController {
    // MARK: - UI
    private let tradeBotLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.tradeBotLabelText
        label.font = .systemFont(ofSize: Constants.tradeBotLabelFontSize)
        label.textColor = Constants.tradeBotLabelTextColor
        return label
    }()
    
    private let sloganLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.sloganLabelText
        label.font = .systemFont(ofSize: Constants.sloganLabelFontSize)
        label.textColor = Constants.sloganLabelTextColor
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.imageName)
        return imageView
    }()
    
    private let progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progress = .zero
        progressView.progressTintColor = Constants.progressViewTintColor
        return progressView
    }()
    
    // MARK: Delegate
    weak var delegate: SplashFinishedProtocol?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupConstraints()
        animateProgress()
    }
}

// MARK: - Setup
private extension SplashScreenViewController {
    func setup() {
        view.backgroundColor = Constants.backgroundColor
        
        view.addSubview(tradeBotLabel)
        view.addSubview(sloganLabel)
        view.addSubview(imageView)
        view.addSubview(progressView)
    }
}

// MARK: - Constraints
private extension SplashScreenViewController {
    func setupConstraints() {
        tradeBotLabel.translatesAutoresizingMaskIntoConstraints = false
        sloganLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tradeBotLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.tradeBotLabelTopInset),
            tradeBotLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            sloganLabel.topAnchor.constraint(equalTo: tradeBotLabel.bottomAnchor, constant: Constants.sloganLabelTopInset),
            sloganLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            imageView.topAnchor.constraint(equalTo: sloganLabel.bottomAnchor, constant: Constants.imageViewTopInset),
//            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.imageViewHorizontalInset),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.imageViewHorizontalInset),
            
            progressView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.progressViewTopInset),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.widthAnchor.constraint(equalToConstant: Constants.progressViewWidth),
            progressView.heightAnchor.constraint(equalToConstant: Constants.progressViewHeight),
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.progressViewBottomInset)
        ])
    }
}

// MARK: - Private Methods
private extension SplashScreenViewController {
    func animateProgress() {
        var progress = Constants.initialProgress
        
        Timer.scheduledTimer(withTimeInterval: Constants.progressTimerInterval, repeats: true) { [weak self] timer in
                guard let self else {
                    timer.invalidate()
                    return
                }
                
                progress += Constants.progressStep
                let clampedProgress = min(progress, Constants.completedProgress)
                let alpha = CGFloat(Constants.visibleAlpha - clampedProgress)
                
                tradeBotLabel.alpha = alpha
                imageView.alpha = alpha
                sloganLabel.alpha = alpha
                progressView.setProgress(clampedProgress, animated: true)
                
                if clampedProgress >= Constants.completedProgress {
                    timer.invalidate()
                    delegate?.splashDidFinished()
                }
            }
    }
}

// MARK: - Constants
private extension SplashScreenViewController {
    enum Constants {
        static let imageName: String = "BotScreen"
        static let tradeBotLabelText: String = "TradeBot"
        static let tradeBotLabelFontSize: CGFloat = 30
        static let tradeBotLabelTextColor: UIColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let sloganLabelText: String = "It's impossible not to make money"
        static let sloganLabelFontSize: CGFloat = 17
        static let sloganLabelTextColor: UIColor = UIColor.black
        static let backgroundColor: UIColor = .white
        static let progressViewTintColor: UIColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let tradeBotLabelTopInset: CGFloat = 116
        static let sloganLabelTopInset: CGFloat = 8
        static let imageViewTopInset: CGFloat = 20
        static let imageViewHorizontalInset: CGFloat = 77
        static let progressViewTopInset: CGFloat = 20
        static let progressViewWidth: CGFloat = 140
        static let progressViewHeight: CGFloat = 20
        static let progressViewBottomInset: CGFloat = 50
        static let initialProgress: Float = 0
        static let progressTimerInterval: TimeInterval = 0.05
        static let progressStep: Float = 0.01
        static let completedProgress: Float = 1.0
        static let visibleAlpha: Float = 1
    }
}
