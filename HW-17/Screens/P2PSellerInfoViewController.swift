import UIKit

final class P2PSellerInfoViewController: UIViewController {
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    private let headerContainerView = UIView()
    private let sellerNameLabel = UILabel()
    private let verificationLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let detailsContainerView = UIView()
    private let detailsStackView = UIStackView()
    private let ratingLabel = UILabel()
    private let completedTradesLabel = UILabel()
    private let responseTimeLabel = UILabel()
    private let paymentMethodsLabel = UILabel()
    private let rateLabel = UILabel()
    private let reserveLabel = UILabel()
    
    // MARK: - Dependencies
    private let viewModel: P2PSellerInfoViewModel
    
    // MARK: - Lifecycle
    init(viewModel: P2PSellerInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationItem()
        setupStackView()
        setupHeaderView()
        setupDetailsView()
        setupHierarchy()
        setupConstraints()
        render(viewModel.viewState)
    }
}

// MARK: - Setup
private extension P2PSellerInfoViewController {
    func setupView() {
        view.backgroundColor = Constants.backgroundColor
    }
    
    func setupNavigationItem() {
        navigationItem.title = Constants.screenTitle
        navigationController?.navigationBar.tintColor = Constants.primaryColor
    }
    
    func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
    }
    
    func setupHeaderView() {
        headerContainerView.backgroundColor = Constants.containerColor
        headerContainerView.layer.cornerRadius = Constants.containerCornerRadius
        headerContainerView.layer.borderWidth = Constants.containerBorderWidth
        headerContainerView.layer.borderColor = Constants.containerBorderColor
        
        sellerNameLabel.font = .systemFont(ofSize: Constants.titleFontSize, weight: .semibold)
        sellerNameLabel.textColor = Constants.primaryTextColor
        sellerNameLabel.numberOfLines = Constants.labelNumberOfLines
        
        verificationLabel.font = .systemFont(ofSize: Constants.statusFontSize, weight: .medium)
        verificationLabel.textColor = Constants.primaryColor
        verificationLabel.numberOfLines = Constants.labelNumberOfLines
        
        descriptionLabel.font = .systemFont(ofSize: Constants.descriptionFontSize)
        descriptionLabel.textColor = Constants.secondaryTextColor
        descriptionLabel.numberOfLines = Constants.labelNumberOfLines
    }
    
    func setupDetailsView() {
        detailsContainerView.backgroundColor = Constants.containerColor
        detailsContainerView.layer.cornerRadius = Constants.containerCornerRadius
        detailsContainerView.layer.borderWidth = Constants.containerBorderWidth
        detailsContainerView.layer.borderColor = Constants.containerBorderColor
        
        detailsStackView.axis = .vertical
        detailsStackView.spacing = Constants.detailsStackSpacing
        
        [
            ratingLabel,
            completedTradesLabel,
            responseTimeLabel,
            paymentMethodsLabel,
            rateLabel,
            reserveLabel
        ].forEach {
            configureDetailLabel($0)
        }
    }
    
    func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(headerContainerView)
        stackView.addArrangedSubview(detailsContainerView)
        
        headerContainerView.addSubview(sellerNameLabel)
        headerContainerView.addSubview(verificationLabel)
        headerContainerView.addSubview(descriptionLabel)
        
        detailsContainerView.addSubview(detailsStackView)
        detailsStackView.addArrangedSubview(ratingLabel)
        detailsStackView.addArrangedSubview(completedTradesLabel)
        detailsStackView.addArrangedSubview(responseTimeLabel)
        detailsStackView.addArrangedSubview(paymentMethodsLabel)
        detailsStackView.addArrangedSubview(rateLabel)
        detailsStackView.addArrangedSubview(reserveLabel)
    }
    
    func configureDetailLabel(_ label: UILabel) {
        label.font = .systemFont(ofSize: Constants.detailFontSize, weight: .medium)
        label.textColor = Constants.primaryTextColor
        label.numberOfLines = Constants.labelNumberOfLines
    }
}

// MARK: - Constraints
private extension P2PSellerInfoViewController {
    func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        sellerNameLabel.translatesAutoresizingMaskIntoConstraints = false
        verificationLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.verticalInset),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalInset),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.verticalInset),
            
            sellerNameLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: Constants.containerContentInset),
            sellerNameLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: Constants.containerContentInset),
            sellerNameLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -Constants.containerContentInset),
            
            verificationLabel.topAnchor.constraint(equalTo: sellerNameLabel.bottomAnchor, constant: Constants.statusTopSpacing),
            verificationLabel.leadingAnchor.constraint(equalTo: sellerNameLabel.leadingAnchor),
            verificationLabel.trailingAnchor.constraint(equalTo: sellerNameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: verificationLabel.bottomAnchor, constant: Constants.descriptionTopSpacing),
            descriptionLabel.leadingAnchor.constraint(equalTo: sellerNameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: sellerNameLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -Constants.containerContentInset),
            
            detailsStackView.topAnchor.constraint(equalTo: detailsContainerView.topAnchor, constant: Constants.containerContentInset),
            detailsStackView.leadingAnchor.constraint(equalTo: detailsContainerView.leadingAnchor, constant: Constants.containerContentInset),
            detailsStackView.trailingAnchor.constraint(equalTo: detailsContainerView.trailingAnchor, constant: -Constants.containerContentInset),
            detailsStackView.bottomAnchor.constraint(equalTo: detailsContainerView.bottomAnchor, constant: -Constants.containerContentInset)
        ])
    }
}

// MARK: - View State
private extension P2PSellerInfoViewController {
    func render(_ state: P2PSellerInfoViewModel.ViewState) {
        sellerNameLabel.text = state.sellerNameText
        verificationLabel.text = state.verificationText
        descriptionLabel.text = state.descriptionText
        ratingLabel.text = state.ratingText
        completedTradesLabel.text = state.completedTradesText
        responseTimeLabel.text = state.responseTimeText
        paymentMethodsLabel.text = state.paymentMethodsText
        rateLabel.text = state.rateText
        reserveLabel.text = state.reserveText
    }
}

// MARK: - Constants
private extension P2PSellerInfoViewController {
    enum Constants {
        static let screenTitle = "Seller"
        static let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 1.00, alpha: 1)
        static let containerColor: UIColor = .white
        static let primaryColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let primaryTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let secondaryTextColor = UIColor(red: 0.39, green: 0.40, blue: 0.58, alpha: 1)
        static let containerBorderColor = UIColor(red: 0.88, green: 0.86, blue: 0.95, alpha: 1).cgColor
        static let horizontalInset: CGFloat = 24
        static let verticalInset: CGFloat = 16
        static let containerContentInset: CGFloat = 16
        static let stackSpacing: CGFloat = 12
        static let detailsStackSpacing: CGFloat = 12
        static let statusTopSpacing: CGFloat = 6
        static let descriptionTopSpacing: CGFloat = 12
        static let containerCornerRadius: CGFloat = 6
        static let containerBorderWidth: CGFloat = 1
        static let titleFontSize: CGFloat = 24
        static let statusFontSize: CGFloat = 15
        static let descriptionFontSize: CGFloat = 15
        static let detailFontSize: CGFloat = 16
        static let labelNumberOfLines = 0
    }
}
