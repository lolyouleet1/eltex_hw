import UIKit

final class BotViewController: UIViewController {
    // MARK: - UI
    private let stackView = UIStackView()
    private let balanceLabel = UILabel()
    private let profitLabel = UILabel()
    private let startBotButton = UIButton(type: .system)
    
    private let cyclesInputContainerView = UIView()
    private let cyclesTextField = UITextField()
    
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
    private let graphViewControllerFactory: (TradingRunResult?) -> GraphViewController
    
    // MARK: - Lifecycle
    init(
        viewModel: BotViewModel,
        compactCurrenciesViewControllerFactory: @escaping (SelectedSide) -> CompactCurrenciesViewController,
        graphViewControllerFactory: @escaping (TradingRunResult?) -> GraphViewController
    ) {
        self.viewModel = viewModel
        self.compactCurrenciesViewControllerFactory = compactCurrenciesViewControllerFactory
        self.graphViewControllerFactory = graphViewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        setupHierarchy()
        setupStackView()
        setupCurrenciesView()
        setupCyclesInputSection()
        setupNoDataLabel()
        setupActions()
        setupConstraints()
        setupBarItems()
        setupSwipeUpGesture()
        render(viewModel.viewState)
    }
}

// MARK: - Setup
private extension BotViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
        view.isUserInteractionEnabled = true
    }
    
    func setupTableView() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func setupHierarchy() {
        view.addSubview(stackView)
        view.addSubview(cyclesInputContainerView)
        view.addSubview(noDataLabel)
        view.addSubview(tableView)
        
        cyclesInputContainerView.addSubview(botControlView)
        cyclesInputContainerView.addSubview(cyclesTextField)
        cyclesInputContainerView.addSubview(currenciesView)
        
        botControlView.addSubview(botEnabledSwitch)
        botControlView.addSubview(botEnabledLabel)
    }
    
    func setupStackView() {
        balanceLabel.backgroundColor = Constants.neutralResultColor
        balanceLabel.textColor = Constants.resultTextColor
        
        profitLabel.backgroundColor = Constants.neutralResultColor
        profitLabel.textColor = Constants.resultTextColor
        
        startBotButton.setTitle(Constants.startBotButtonTitle, for: .normal)
        startBotButton.backgroundColor = Constants.startBotButtonBackgroundColor
        startBotButton.tintColor = Constants.startBotButtonTintColor
        startBotButton.layer.cornerRadius = Constants.buttonCornerRadius
        
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        
        stackView.addArrangedSubview(balanceLabel)
        stackView.addArrangedSubview(profitLabel)
        stackView.addArrangedSubview(startBotButton)
    }
    
    func setupCurrenciesView() {
        currenciesView.backgroundColor = Constants.currenciesBackgroundColor
        
        leftCurrencyLabel.backgroundColor = Constants.currencyLabelBackgroundColor
        leftCurrencyLabel.textAlignment = .center
        leftCurrencyLabel.isUserInteractionEnabled = true
        
        rightCurrencyLabel.backgroundColor = Constants.currencyLabelBackgroundColor
        rightCurrencyLabel.textAlignment = .center
        rightCurrencyLabel.isUserInteractionEnabled = true
        
        currenciesView.addSubview(leftCurrencyLabel)
        currenciesView.addSubview(rightCurrencyLabel)
    }
    
    func setupCyclesInputSection() {
        cyclesTextField.placeholder = Constants.cyclesPlaceholder
        cyclesTextField.borderStyle = .roundedRect
        
        botEnabledSwitch.isOn = Constants.isBotEnabledByDefault
        botEnabledLabel.text = Constants.botEnabledLabelText
    }
    
    func setupNoDataLabel() {
        noDataLabel.text = Constants.warningText
        noDataLabel.backgroundColor = Constants.warningBackgroundColor
    }
    
    func setupActions() {
        startBotButton.addTarget(
            self,
            action: #selector(handleStartBotButtonTapped),
            for: .touchUpInside
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
    
    func setupBarItems() {
        title = Constants.screenTitle
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.clearButtonImageName),
            style: .plain,
            target: self,
            action: #selector(handleLeftBarButtonItem)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.randomizeButtonImageName),
            style: .plain,
            target: self,
            action: #selector(handleRightBarButtonItem)
        )
    }
    
    func setupSwipeUpGesture() {
        let viewSwipeUpGesture = UISwipeGestureRecognizer(
            target: self,
            action: #selector(handleSwipeUpGesture)
        )
        viewSwipeUpGesture.direction = .up
        
        view.addGestureRecognizer(viewSwipeUpGesture)
    }
}

// MARK: - Handle Swipe Up Gesture
private extension BotViewController {
    @objc func handleSwipeUpGesture() {
        let viewController = graphViewControllerFactory(viewModel.makeGraphResult())
        navigationController?.pushViewController(viewController, animated: true)
    }
}

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
        balanceLabel.text = state.balanceText
        profitLabel.text = state.profitText
        balanceLabel.backgroundColor = makeColor(for: state.balanceTone)
        profitLabel.backgroundColor = makeColor(for: state.profitTone)
        
        leftCurrencyLabel.text = state.leftCurrencyText
        rightCurrencyLabel.text = state.rightCurrencyText
        
        noDataLabel.isHidden = state.isWarningHidden
        tableView.isHidden = state.isTableHidden
        tableView.reloadData()
    }
    
    func makeColor(for tone: ResultTone) -> UIColor {
        switch tone {
        case .neutral:
            return Constants.neutralResultColor
        case .positive:
            return Constants.positiveResultColor
        case .negative:
            return Constants.negativeResultColor
        }
    }
}

// MARK: - Business Logic
private extension BotViewController {
    @objc func handleStartBotButtonTapped() {
        viewModel.handleStart(
            cyclesText: cyclesTextField.text,
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
        cyclesTextField.translatesAutoresizingMaskIntoConstraints = false
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
            
            cyclesInputContainerView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.topInset),
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
            
            cyclesTextField.leadingAnchor.constraint(equalTo: currenciesView.trailingAnchor, constant: Constants.imageToFieldSpacing),
            cyclesTextField.trailingAnchor.constraint(equalTo: cyclesInputContainerView.trailingAnchor),
            cyclesTextField.centerYAnchor.constraint(equalTo: currenciesView.centerYAnchor),
            
            botControlView.topAnchor.constraint(equalTo: currenciesView.bottomAnchor, constant: Constants.switchSectionTopSpacing),
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
            stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Constants.topInset),
            
            tableView.topAnchor.constraint(equalTo: cyclesInputContainerView.bottomAnchor, constant: Constants.sectionSpacing),
            tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.tableHorizontalInset),
            tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.tableHorizontalInset),
            tableView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -Constants.sectionSpacing)
        ])
    }
}

// MARK: - Navigation Bar
private extension BotViewController {
    @objc func handleLeftBarButtonItem() {
        viewModel.handleClear()
        render(viewModel.viewState)
    }
    
    @objc func handleRightBarButtonItem() {
        viewModel.handleRandomCurrencies()
        render(viewModel.viewState)
    }
}

// MARK: - UITableViewDataSource
extension BotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.viewState.operations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier) as? TableViewCell else {
            return UITableViewCell(style: .default, reuseIdentifier: nil)
        }
        
        cell.currentOperation = viewModel.viewState.operations[indexPath.row]
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
        static let startBotButtonTitle = "START BOT"
        static let cyclesPlaceholder = "How many operations?"
        static let botEnabledLabelText = "Allow the bot to work:"
        static let warningText = "WARNING: not enough data"
        static let clearButtonImageName = "trash"
        static let randomizeButtonImageName = "bitcoinsign.bank.building"
        static let isBotEnabledByDefault = true
        static let neutralResultColor: UIColor = .gray
        static let positiveResultColor: UIColor = .green
        static let negativeResultColor: UIColor = .red
        static let resultTextColor: UIColor = .black
        static let startBotButtonBackgroundColor: UIColor = .purple
        static let startBotButtonTintColor: UIColor = .white
        static let currenciesBackgroundColor: UIColor = .white
        static let currencyLabelBackgroundColor: UIColor = .orange
        static let warningBackgroundColor: UIColor = .red
        static let stackSpacing: CGFloat = 8
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let imageToFieldSpacing: CGFloat = 16
        static let switchSectionTopSpacing: CGFloat = 16
        static let switchTopSpacing: CGFloat = 8
        static let buttonCornerRadius: CGFloat = 15
        static let tableHorizontalInset: CGFloat = 8
        static let currenciesViewHeight: CGFloat = 20
        static let currenciesViewWidth: CGFloat = 130
        static let currencyLabelSpacing: CGFloat = 6
    }
}
