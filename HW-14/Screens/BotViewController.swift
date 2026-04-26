import UIKit

final class BotViewController: UIViewController {
    // MARK: - UI
    private let stackView = UIStackView()
    private let startBotButton = UIButton(type: .system)
    
    private let cyclesInputContainerView = UIView()
    private let botAmountTextField = UITextField()
    private let botLimitLabel = UILabel()
    
    private let currenciesView = UIView()
    private let leftCurrencyLabel = UILabel()
    private let rightCurrencyLabel = UILabel()
    
    private let botControlView = UIView()
    private let botEnabledSwitch = UISwitch()
    private let botEnabledLabel = UILabel()
    
    private let noDataLabel = UILabel()
    private let tableView = UITableView()
    
    // MARK: - Dependencies
    private let viewModel: BotViewModel
    private let compactCurrenciesViewControllerFactory: (SelectedSide) -> CompactCurrenciesViewController
    private let walletViewControllerFactory: () -> WalletViewController
//    private let graphViewControllerFactory: (TradingRunResult?) -> GraphViewController
    
    // MARK: - Lifecycle
    init(viewModel: BotViewModel, compactCurrenciesViewControllerFactory: @escaping (SelectedSide) -> CompactCurrenciesViewController, walletViewControllerFactory: @escaping () -> WalletViewController) {
        self.viewModel = viewModel
        self.compactCurrenciesViewControllerFactory = compactCurrenciesViewControllerFactory
        self.walletViewControllerFactory = walletViewControllerFactory
//        self.graphViewControllerFactory = graphViewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        
        setupNavigationItem()
        setupView()
        setupTableView()
        setupHierarchy()
        setupStackView()
        setupCurrenciesView()
        setupCyclesInputSection()
        setupNoDataLabel()
        setupActions()
        setupConstraints()
//        setupSwipeUpGesture()
        render(viewModel.viewState)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Setup
private extension BotViewController {
    func setupNavigationItem() {
        navigationItem.title = Constants.screenTitle
        navigationController?.navigationBar.tintColor = Constants.primaryColor
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.clearButtonImageName),
            style: .plain,
            target: self,
            action: #selector(handleClearButtonTapped)
        )
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: Constants.walletButtonImageName),
                style: .plain,
                target: self,
                action: #selector(handleWalletButtonTapped)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: Constants.randomizeButtonImageName),
                style: .plain,
                target: self,
                action: #selector(handleRandomCurrenciesButtonTapped)
            )
        ]
    }
    
    func setupView() {
        view.backgroundColor = Constants.backgroundColor
        view.isUserInteractionEnabled = true
    }
    
    func setupTableView() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.dataSource = self
        tableView.backgroundColor = Constants.tableBackgroundColor
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Constants.tableSeparatorColor
        tableView.separatorInset = .zero
        tableView.rowHeight = Constants.tableRowHeight
        tableView.estimatedRowHeight = Constants.tableRowHeight
        tableView.layer.cornerRadius = Constants.tableCornerRadius
        tableView.layer.borderWidth = Constants.tableBorderWidth
        tableView.layer.borderColor = Constants.tableBorderColor
        tableView.clipsToBounds = true
    }
    
    func setupHierarchy() {
        view.addSubview(stackView)
        view.addSubview(cyclesInputContainerView)
        view.addSubview(noDataLabel)
        view.addSubview(tableView)
        
        cyclesInputContainerView.addSubview(botControlView)
        cyclesInputContainerView.addSubview(botAmountTextField)
        cyclesInputContainerView.addSubview(botLimitLabel)
        cyclesInputContainerView.addSubview(currenciesView)
        
        botControlView.addSubview(botEnabledSwitch)
        botControlView.addSubview(botEnabledLabel)
    }
    
    func setupStackView() {
        startBotButton.setTitle(viewModel.viewState.startButtonTitle, for: .normal)
        startBotButton.backgroundColor = Constants.primaryColor
        startBotButton.tintColor = Constants.startBotButtonTintColor
        startBotButton.titleLabel?.font = .systemFont(ofSize: Constants.startBotButtonFontSize, weight: .medium)
        startBotButton.layer.cornerRadius = Constants.buttonCornerRadius
        
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        
        stackView.addArrangedSubview(startBotButton)
    }
    
    func setupCurrenciesView() {
        currenciesView.backgroundColor = Constants.clearColor
        
        leftCurrencyLabel.backgroundColor = Constants.primaryColor
        leftCurrencyLabel.textColor = Constants.currencyLabelTextColor
        leftCurrencyLabel.font = .systemFont(ofSize: Constants.currencyLabelFontSize, weight: .medium)
        leftCurrencyLabel.textAlignment = .center
        leftCurrencyLabel.isUserInteractionEnabled = true
        leftCurrencyLabel.layer.cornerRadius = Constants.currencyLabelCornerRadius
        leftCurrencyLabel.clipsToBounds = true
        
        rightCurrencyLabel.backgroundColor = Constants.primaryColor
        rightCurrencyLabel.textColor = Constants.currencyLabelTextColor
        rightCurrencyLabel.font = .systemFont(ofSize: Constants.currencyLabelFontSize, weight: .medium)
        rightCurrencyLabel.textAlignment = .center
        rightCurrencyLabel.isUserInteractionEnabled = true
        rightCurrencyLabel.layer.cornerRadius = Constants.currencyLabelCornerRadius
        rightCurrencyLabel.clipsToBounds = true
        
        currenciesView.addSubview(leftCurrencyLabel)
        currenciesView.addSubview(rightCurrencyLabel)
    }
    
    func setupCyclesInputSection() {
        botAmountTextField.placeholder = Constants.cyclesPlaceholder
        botAmountTextField.borderStyle = .none
        botAmountTextField.backgroundColor = Constants.textFieldBackgroundColor
        botAmountTextField.textColor = Constants.primaryTextColor
        botAmountTextField.font = .systemFont(ofSize: Constants.textFieldFontSize)
        botAmountTextField.layer.cornerRadius = Constants.textFieldCornerRadius
        botAmountTextField.layer.borderWidth = Constants.textFieldBorderWidth
        botAmountTextField.layer.borderColor = Constants.textFieldBorderColor
        botAmountTextField.leftView = UIView(
            frame: CGRect(
                x: .zero,
                y: .zero,
                width: Constants.textFieldHorizontalPadding,
                height: Constants.textFieldHeight
            )
        )
        botAmountTextField.leftViewMode = .always
        
        botLimitLabel.textColor = Constants.secondaryTextColor
        botLimitLabel.font = .systemFont(ofSize: Constants.botLimitLabelFontSize)
        botLimitLabel.numberOfLines = Constants.botLimitLabelNumberOfLines
        
        botEnabledSwitch.isOn = Constants.isBotEnabledByDefault
        botEnabledSwitch.onTintColor = Constants.primaryColor
        botEnabledSwitch.thumbTintColor = Constants.switchThumbColor
        botEnabledLabel.text = Constants.botEnabledLabelText
        botEnabledLabel.textColor = Constants.primaryTextColor
        botEnabledLabel.font = .systemFont(ofSize: Constants.controlLabelFontSize)
    }
    
    func setupNoDataLabel() {
        noDataLabel.text = viewModel.viewState.warningText
        noDataLabel.textColor = Constants.sellTextColor
        noDataLabel.backgroundColor = Constants.sellBackgroundColor
        noDataLabel.layer.cornerRadius = Constants.metricCornerRadius
        noDataLabel.clipsToBounds = true
    }
    
    func setupActions() {
        startBotButton.addTarget(
            self,
            action: #selector(handleStartBotButtonTapped),
            for: .touchUpInside
        )
        botAmountTextField.addTarget(
            self,
            action: #selector(handleBotsAmountEditingChanged),
            for: .editingChanged
        )
        
        setupLeftCurrencyGesture()
        setupRightCurrencyGesture()
    }
    
    func setupLeftCurrencyGesture() {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCurrencyTapped(_:))
        )
        
        leftCurrencyLabel.addGestureRecognizer(gesture)
    }
    
    func setupRightCurrencyGesture() {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCurrencyTapped(_:))
        )
        
        rightCurrencyLabel.addGestureRecognizer(gesture)
    }
    
//    func setupSwipeUpGesture() {
//        let viewSwipeUpGesture = UISwipeGestureRecognizer(
//            target: self,
//            action: #selector(handleSwipeUpGesture)
//        )
//        viewSwipeUpGesture.direction = .up
//        
//        view.addGestureRecognizer(viewSwipeUpGesture)
//    }
}

// MARK: - Graph
//private extension BotViewController {
//    @objc func handleSwipeUpGesture() {
//        let viewController = graphViewControllerFactory(viewModel.makeGraphResult())
//        
//        viewModel.onTradingResultChange = { [weak viewController] result in
//            viewController?.update(tradingResult: result)
//        }
//        
//        navigationController?.pushViewController(viewController, animated: true)
//    }
//}

// MARK: - Currency Selection
private extension BotViewController {
    @objc func handleCurrencyTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        
        let selectionSide: SelectedSide = tappedLabel == leftCurrencyLabel ? .left : .right
        let viewController = compactCurrenciesViewControllerFactory(selectionSide)
        viewController.delegate = self
        
        present(viewController, animated: true)
    }
}

// MARK: - View State
private extension BotViewController {
    func render(_ state: BotViewModel.ViewState) {
        noDataLabel.text = state.warningText
        leftCurrencyLabel.text = state.leftCurrencyText
        rightCurrencyLabel.text = state.rightCurrencyText
        botLimitLabel.text = state.botLimitText
        startBotButton.setTitle(state.startButtonTitle, for: .normal)
        startBotButton.isEnabled = state.isStartButtonEnabled
        startBotButton.alpha = state.isStartButtonEnabled ? Constants.enabledAlpha : Constants.disabledAlpha
        
        noDataLabel.isHidden = state.isWarningHidden
        tableView.isHidden = state.isTableHidden
        tableView.reloadData()
    }
}

// MARK: - Business Logic
private extension BotViewController {
    @objc func handleBotsAmountEditingChanged() {
        viewModel.handleBotsAmountChange(botAmountTextField.text)
    }
    
    @objc func handleStartBotButtonTapped() {
        viewModel.handleStart(
            botsAmount: botAmountTextField.text,
            isBotEnabled: botEnabledSwitch.isOn
        )
        
        render(viewModel.viewState)
    }
}

// MARK: - Constraints
private extension BotViewController {
    func setupConstraints() {
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        botControlView.translatesAutoresizingMaskIntoConstraints = false
        botAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        botLimitLabel.translatesAutoresizingMaskIntoConstraints = false
        botEnabledLabel.translatesAutoresizingMaskIntoConstraints = false
        botEnabledSwitch.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cyclesInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        currenciesView.translatesAutoresizingMaskIntoConstraints = false
        leftCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        rightCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            
            cyclesInputContainerView.topAnchor.constraint(
                equalTo: guide.topAnchor,
                constant: Constants.contentTopInset
            ),
            cyclesInputContainerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            cyclesInputContainerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            
            currenciesView.heightAnchor.constraint(equalToConstant: Constants.currenciesViewHeight),
            currenciesView.widthAnchor.constraint(equalToConstant: Constants.currenciesViewWidth),
            
            leftCurrencyLabel.bottomAnchor.constraint(equalTo: currenciesView.bottomAnchor),
            leftCurrencyLabel.topAnchor.constraint(equalTo: currenciesView.topAnchor),
            leftCurrencyLabel.leadingAnchor.constraint(equalTo: currenciesView.leadingAnchor),
            leftCurrencyLabel.trailingAnchor.constraint(equalTo: currenciesView.centerXAnchor, constant: -Constants.currencyLabelSpacing),
            
            rightCurrencyLabel.topAnchor.constraint(equalTo: currenciesView.topAnchor),
            rightCurrencyLabel.bottomAnchor.constraint(equalTo: currenciesView.bottomAnchor),
            rightCurrencyLabel.leadingAnchor.constraint(equalTo: currenciesView.centerXAnchor, constant: Constants.currencyLabelSpacing),
            rightCurrencyLabel.trailingAnchor.constraint(equalTo: currenciesView.trailingAnchor),
            
            currenciesView.topAnchor.constraint(equalTo: cyclesInputContainerView.topAnchor),
            currenciesView.leadingAnchor.constraint(equalTo: cyclesInputContainerView.leadingAnchor),
            
            botAmountTextField.leadingAnchor.constraint(equalTo: currenciesView.trailingAnchor, constant: Constants.imageToFieldSpacing),
            botAmountTextField.trailingAnchor.constraint(equalTo: cyclesInputContainerView.trailingAnchor),
            botAmountTextField.centerYAnchor.constraint(equalTo: currenciesView.centerYAnchor),
            botAmountTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            botLimitLabel.topAnchor.constraint(equalTo: botAmountTextField.bottomAnchor, constant: Constants.botLimitTopSpacing),
            botLimitLabel.leadingAnchor.constraint(equalTo: botAmountTextField.leadingAnchor),
            botLimitLabel.trailingAnchor.constraint(equalTo: botAmountTextField.trailingAnchor),
            
            botControlView.topAnchor.constraint(equalTo: botLimitLabel.bottomAnchor, constant: Constants.switchSectionTopSpacing),
            botControlView.leadingAnchor.constraint(equalTo: cyclesInputContainerView.leadingAnchor),
            botControlView.trailingAnchor.constraint(equalTo: cyclesInputContainerView.trailingAnchor),
            botControlView.bottomAnchor.constraint(equalTo: cyclesInputContainerView.bottomAnchor),
            
            botEnabledLabel.topAnchor.constraint(equalTo: botControlView.topAnchor),
            botEnabledLabel.leadingAnchor.constraint(equalTo: botControlView.leadingAnchor),
            botEnabledLabel.trailingAnchor.constraint(lessThanOrEqualTo: botControlView.trailingAnchor),
            
            botEnabledSwitch.topAnchor.constraint(equalTo: botEnabledLabel.bottomAnchor, constant: Constants.switchTopSpacing),
            botEnabledSwitch.leadingAnchor.constraint(equalTo: botControlView.leadingAnchor),
            botEnabledSwitch.bottomAnchor.constraint(equalTo: botControlView.bottomAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Constants.bottomInset),
            
            startBotButton.heightAnchor.constraint(equalToConstant: Constants.startBotButtonHeight),
            
            tableView.topAnchor.constraint(equalTo: cyclesInputContainerView.bottomAnchor, constant: Constants.sectionSpacing),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            tableView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -Constants.sectionSpacing)
        ])
    }
}

// MARK: - Actions
private extension BotViewController {
    @objc func handleClearButtonTapped() {
        viewModel.handleClear()
        render(viewModel.viewState)
    }
    
    @objc func handleRandomCurrenciesButtonTapped() {
        viewModel.handleRandomCurrencies()
        render(viewModel.viewState)
    }
    
    @objc func handleWalletButtonTapped() {
        let viewController = walletViewControllerFactory()
        let navigationController = UINavigationController(rootViewController: viewController)
        
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension BotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.viewState.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier) as? TableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        cell.currentResult = viewModel.viewState.results[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - CompactCurrenciesViewControllerDelegate
extension BotViewController: CompactCurrenciesViewControllerDelegate {
    func compactCurrenciesViewController(didSelect currency: Currency, for side: SelectedSide) {
        viewModel.handleCurrencySelection(currency, for: side)
        render(viewModel.viewState)
    }
}

// MARK: - Constants
private extension BotViewController {
    enum Constants {
        static let screenTitle = "Bot"
        static let cyclesPlaceholder = "Bots amount"
        static let botEnabledLabelText = "Allow the bot to work:"
        static let clearButtonImageName = "trash"
        static let walletButtonImageName = "creditcard"
        static let randomizeButtonImageName = "bitcoinsign.bank.building"
        static let isBotEnabledByDefault = true
        static let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 1.00, alpha: 1)
        static let primaryColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let primaryTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let secondaryTextColor = UIColor(red: 0.39, green: 0.40, blue: 0.58, alpha: 1)
        static let sellTextColor = UIColor(red: 0.86, green: 0.15, blue: 0.26, alpha: 1)
        static let sellBackgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.98, alpha: 1)
        static let startBotButtonTintColor: UIColor = .white
        static let currencyLabelTextColor: UIColor = .white
        static let textFieldBackgroundColor: UIColor = .white
        static let switchThumbColor: UIColor = .white
        static let tableBackgroundColor: UIColor = .white
        static let tableSeparatorColor = UIColor(red: 0.90, green: 0.89, blue: 0.96, alpha: 1)
        static let tableBorderColor = UIColor(red: 0.88, green: 0.86, blue: 0.95, alpha: 1).cgColor
        static let textFieldBorderColor = UIColor(red: 0.86, green: 0.85, blue: 0.92, alpha: 1).cgColor
        static let clearColor: UIColor = .clear
        static let stackSpacing: CGFloat = 8
        static let horizontalInset: CGFloat = 24
        static let contentTopInset: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let bottomInset: CGFloat = 18
        static let imageToFieldSpacing: CGFloat = 8
        static let switchSectionTopSpacing: CGFloat = 22
        static let switchTopSpacing: CGFloat = 8
        static let buttonCornerRadius: CGFloat = 22
        static let metricCornerRadius: CGFloat = 6
        static let tableCornerRadius: CGFloat = 6
        static let tableBorderWidth: CGFloat = 1
        static let currenciesViewHeight: CGFloat = 34
        static let currenciesViewWidth: CGFloat = 146
        static let currencyLabelSpacing: CGFloat = 8
        static let currencyLabelCornerRadius: CGFloat = 3
        static let currencyLabelFontSize: CGFloat = 17
        static let textFieldHeight: CGFloat = 34
        static let textFieldCornerRadius: CGFloat = 4
        static let textFieldBorderWidth: CGFloat = 1
        static let textFieldHorizontalPadding: CGFloat = 14
        static let textFieldFontSize: CGFloat = 17
        static let controlLabelFontSize: CGFloat = 17
        static let botLimitLabelFontSize: CGFloat = 13
        static let botLimitLabelNumberOfLines = 0
        static let botLimitTopSpacing: CGFloat = 6
        static let startBotButtonFontSize: CGFloat = 17
        static let startBotButtonHeight: CGFloat = 44
        static let tableRowHeight: CGFloat = 56
        static let enabledAlpha: CGFloat = 1
        static let disabledAlpha: CGFloat = 0.55
    }
}
