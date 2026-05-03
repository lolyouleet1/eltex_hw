import UIKit

final class P2PExchangeViewController: UIViewController {
    // MARK: - UI
    private let topContainerView = UIView()
    private let currenciesView = UIView()
    private let leftCurrencyLabel = UILabel()
    private let rightCurrencyLabel = UILabel()
    private let balancesStackView = UIStackView()
    private let sendBalanceLabel = UILabel()
    private let receiveBalanceLabel = UILabel()
    private let tableView = UITableView()
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Dependencies
    private let viewModel: P2PExchangeViewModel
    private let compactCurrenciesViewControllerFactory: (SelectedSide, [Currency]) -> CompactCurrenciesViewController
    private let walletViewControllerFactory: () -> WalletViewController
    
    // MARK: - Lifecycle
    init(
        viewModel: P2PExchangeViewModel,
        compactCurrenciesViewControllerFactory: @escaping (SelectedSide, [Currency]) -> CompactCurrenciesViewController,
        walletViewControllerFactory: @escaping () -> WalletViewController
    ) {
        self.viewModel = viewModel
        self.compactCurrenciesViewControllerFactory = compactCurrenciesViewControllerFactory
        self.walletViewControllerFactory = walletViewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        setupNavigationItem()
        setupView()
        setupTopContainerView()
        setupCurrenciesView()
        setupBalanceLabels()
        setupTableView()
        setupEmptyStateLabel()
        setupActivityIndicator()
        setupHierarchy()
        setupActions()
        setupConstraints()
        render(viewModel.viewState)
        viewModel.start()
    }
}

// MARK: - Setup
private extension P2PExchangeViewController {
    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        
        viewModel.onAlert = { [weak self] alert in
            self?.showAlert(alert)
        }
    }
    
    func setupNavigationItem() {
        navigationItem.title = Constants.screenTitle
        navigationController?.navigationBar.tintColor = Constants.primaryColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.walletButtonImageName),
            style: .plain,
            target: self,
            action: #selector(handleWalletButtonTapped)
        )
    }
    
    func setupView() {
        view.backgroundColor = Constants.backgroundColor
    }
    
    func setupTopContainerView() {
        topContainerView.backgroundColor = Constants.topContainerBackgroundColor
        topContainerView.layer.cornerRadius = Constants.topContainerCornerRadius
        topContainerView.layer.borderWidth = Constants.topContainerBorderWidth
        topContainerView.layer.borderColor = Constants.topContainerBorderColor
    }
    
    func setupCurrenciesView() {
        currenciesView.backgroundColor = Constants.clearColor
        
        configureCurrencyLabel(leftCurrencyLabel)
        configureCurrencyLabel(rightCurrencyLabel)
        
        currenciesView.addSubview(leftCurrencyLabel)
        currenciesView.addSubview(rightCurrencyLabel)
    }
    
    func setupBalanceLabels() {
        balancesStackView.axis = .vertical
        balancesStackView.spacing = Constants.balanceStackSpacing
        
        [sendBalanceLabel, receiveBalanceLabel].forEach {
            $0.font = .systemFont(ofSize: Constants.balanceFontSize, weight: .medium)
            $0.textColor = Constants.secondaryTextColor
            $0.numberOfLines = Constants.balanceLabelNumberOfLines
        }
    }
    
    func setupTableView() {
        tableView.register(P2POfferCell.self, forCellReuseIdentifier: P2POfferCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Constants.clearColor
        tableView.separatorStyle = .none
        tableView.rowHeight = Constants.tableRowHeight
        tableView.estimatedRowHeight = Constants.tableRowHeight
        tableView.showsVerticalScrollIndicator = false
    }
    
    func setupEmptyStateLabel() {
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = Constants.secondaryTextColor
        emptyStateLabel.font = .systemFont(ofSize: Constants.emptyStateFontSize, weight: .medium)
        emptyStateLabel.numberOfLines = Constants.emptyStateLineCount
    }
    
    func setupActivityIndicator() {
        activityIndicator.color = Constants.primaryColor
        activityIndicator.hidesWhenStopped = true
    }
    
    func setupHierarchy() {
        view.addSubview(topContainerView)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(activityIndicator)
        
        topContainerView.addSubview(currenciesView)
        topContainerView.addSubview(balancesStackView)
        
        balancesStackView.addArrangedSubview(sendBalanceLabel)
        balancesStackView.addArrangedSubview(receiveBalanceLabel)
    }
    
    func setupActions() {
        let leftTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCurrencyTapped(_:))
        )
        leftCurrencyLabel.addGestureRecognizer(leftTapGesture)
        
        let rightTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCurrencyTapped(_:))
        )
        rightCurrencyLabel.addGestureRecognizer(rightTapGesture)
    }
    
    func configureCurrencyLabel(_ label: UILabel) {
        label.backgroundColor = Constants.primaryColor
        label.textColor = Constants.currencyLabelTextColor
        label.font = .systemFont(ofSize: Constants.currencyLabelFontSize, weight: .medium)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.layer.cornerRadius = Constants.currencyLabelCornerRadius
        label.clipsToBounds = true
    }
}

// MARK: - Constraints
private extension P2PExchangeViewController {
    func setupConstraints() {
        topContainerView.translatesAutoresizingMaskIntoConstraints = false
        currenciesView.translatesAutoresizingMaskIntoConstraints = false
        leftCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        rightCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        balancesStackView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            topContainerView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.topInset),
            topContainerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            topContainerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            
            currenciesView.topAnchor.constraint(equalTo: topContainerView.topAnchor, constant: Constants.topContainerContentInset),
            currenciesView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: Constants.topContainerContentInset),
            currenciesView.widthAnchor.constraint(equalToConstant: Constants.currenciesViewWidth),
            currenciesView.heightAnchor.constraint(equalToConstant: Constants.currenciesViewHeight),
            
            leftCurrencyLabel.topAnchor.constraint(equalTo: currenciesView.topAnchor),
            leftCurrencyLabel.bottomAnchor.constraint(equalTo: currenciesView.bottomAnchor),
            leftCurrencyLabel.leadingAnchor.constraint(equalTo: currenciesView.leadingAnchor),
            leftCurrencyLabel.trailingAnchor.constraint(equalTo: currenciesView.centerXAnchor, constant: -Constants.currencyLabelSpacing),
            
            rightCurrencyLabel.topAnchor.constraint(equalTo: currenciesView.topAnchor),
            rightCurrencyLabel.bottomAnchor.constraint(equalTo: currenciesView.bottomAnchor),
            rightCurrencyLabel.leadingAnchor.constraint(equalTo: currenciesView.centerXAnchor, constant: Constants.currencyLabelSpacing),
            rightCurrencyLabel.trailingAnchor.constraint(equalTo: currenciesView.trailingAnchor),
            
            balancesStackView.topAnchor.constraint(equalTo: currenciesView.bottomAnchor, constant: Constants.balanceTopSpacing),
            balancesStackView.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor, constant: Constants.topContainerContentInset),
            balancesStackView.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor, constant: -Constants.topContainerContentInset),
            balancesStackView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: -Constants.topContainerContentInset),
            
            tableView.topAnchor.constraint(equalTo: topContainerView.bottomAnchor, constant: Constants.sectionSpacing),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.tableHorizontalInset),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.tableHorizontalInset),
            tableView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - View State
private extension P2PExchangeViewController {
    func render(_ state: P2PExchangeViewModel.ViewState) {
        leftCurrencyLabel.text = state.leftCurrencyText
        rightCurrencyLabel.text = state.rightCurrencyText
        sendBalanceLabel.text = state.sendBalanceText
        receiveBalanceLabel.text = state.receiveBalanceText
        emptyStateLabel.text = state.emptyStateText
        tableView.isHidden = state.isTableHidden
        emptyStateLabel.isHidden = !state.isTableHidden || state.isLoading
        
        if state.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        tableView.reloadData()
    }
}

// MARK: - Actions
private extension P2PExchangeViewController {
    @objc func handleCurrencyTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        
        let selectionSide: SelectedSide = tappedLabel == leftCurrencyLabel ? .left : .right
        let viewController = compactCurrenciesViewControllerFactory(
            selectionSide,
            viewModel.availableCurrencies()
        )
        viewController.delegate = self
        
        present(viewController, animated: true)
    }
    
    @objc func handleWalletButtonTapped() {
        let viewController = walletViewControllerFactory()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true)
    }
}

// MARK: - Alerts
private extension P2PExchangeViewController {
    func showExchangeAlert(for index: Int) {
        guard let inputViewModel = viewModel.exchangeInputViewModel(for: index) else { return }
        
        let alert = UIAlertController(
            title: inputViewModel.title,
            message: inputViewModel.message,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = inputViewModel.placeholder
            textField.keyboardType = .decimalPad
        }
        
        let executeAction = UIAlertAction(title: inputViewModel.actionTitle, style: .default) { [weak self, weak alert] _ in
            let amountText = alert?.textFields?.first?.text
            self?.viewModel.performExchange(offerIndex: index, amountText: amountText)
        }
        
        alert.addAction(UIAlertAction(title: inputViewModel.cancelTitle, style: .cancel))
        alert.addAction(executeAction)
        
        present(alert, animated: true)
    }
    
    func showAlert(_ viewModel: P2PAlertViewModel) {
        let alert = UIAlertController(
            title: viewModel.title,
            message: viewModel.message,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: Constants.alertButtonTitle,
                style: .default
            )
        )
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension P2PExchangeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.viewState.offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: P2POfferCell.identifier,
            for: indexPath
        ) as? P2POfferCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        cell.configure(with: viewModel.viewState.offers[indexPath.row])
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension P2PExchangeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showExchangeAlert(for: indexPath.row)
    }
}

// MARK: - CompactCurrenciesViewControllerDelegate
extension P2PExchangeViewController: CompactCurrenciesViewControllerDelegate {
    func compactCurrenciesViewController(didSelect currency: Currency, for side: SelectedSide) {
        dismiss(animated: true)
        viewModel.handleCurrencySelection(currency, for: side)
    }
}

// MARK: - Constants
private extension P2PExchangeViewController {
    enum Constants {
        static let screenTitle = "P2P"
        static let walletButtonImageName = "creditcard"
        static let alertButtonTitle = "OK"
        static let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 1.00, alpha: 1)
        static let topContainerBackgroundColor: UIColor = .white
        static let primaryColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let secondaryTextColor = UIColor(red: 0.39, green: 0.40, blue: 0.58, alpha: 1)
        static let currencyLabelTextColor: UIColor = .white
        static let clearColor: UIColor = .clear
        static let topContainerBorderColor = UIColor(red: 0.88, green: 0.86, blue: 0.95, alpha: 1).cgColor
        static let topInset: CGFloat = 16
        static let horizontalInset: CGFloat = 24
        static let tableHorizontalInset: CGFloat = 8
        static let sectionSpacing: CGFloat = 12
        static let topContainerContentInset: CGFloat = 16
        static let balanceTopSpacing: CGFloat = 12
        static let balanceStackSpacing: CGFloat = 6
        static let currenciesViewHeight: CGFloat = 34
        static let currenciesViewWidth: CGFloat = 146
        static let currencyLabelSpacing: CGFloat = 8
        static let currencyLabelCornerRadius: CGFloat = 3
        static let currencyLabelFontSize: CGFloat = 17
        static let balanceFontSize: CGFloat = 15
        static let balanceLabelNumberOfLines = 0
        static let emptyStateFontSize: CGFloat = 17
        static let emptyStateLineCount = 0
        static let topContainerCornerRadius: CGFloat = 6
        static let topContainerBorderWidth: CGFloat = 1
        static let tableRowHeight: CGFloat = 106
    }
}
