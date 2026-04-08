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
    private let stock = Stock(balance: Constants.startBalance)
    private let dataProvider = CurrenciesDataProvider()
    
    // MARK: - State
    private var operations: [Operation] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    private var currentTappedLabel: UILabel?
    
    // MARK: - Lifecycle
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
    }
}

// MARK: - Setup
private extension BotViewController {
    func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    func setupTableView() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func setupHierarchy() {
        view.addSubview(stackView)
        view.addSubview(cyclesInputContainerView)
        view.addSubview(noDataLabel)
        view.addSubview(tableView)
        view.addSubview(currenciesView)
        
        cyclesInputContainerView.addSubview(botControlView)
        cyclesInputContainerView.addSubview(cyclesTextField)
        cyclesInputContainerView.addSubview(currenciesView)
        
        botControlView.addSubview(botEnabledSwitch)
        botControlView.addSubview(botEnabledLabel)
    }
    
    func setupStackView() {
        balanceLabel.text = "Balance: \(stock.balance)"
        balanceLabel.backgroundColor = .gray
        balanceLabel.textColor = .black
        
        profitLabel.text = "Profit: 0"
        profitLabel.backgroundColor = .gray
        profitLabel.textColor = .black
        
        startBotButton.setTitle("START BOT", for: .normal)
        startBotButton.backgroundColor = .purple
        startBotButton.tintColor = .white
        startBotButton.layer.cornerRadius = Constants.buttonCornerRadius
        
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        
        stackView.addArrangedSubview(balanceLabel)
        stackView.addArrangedSubview(profitLabel)
        stackView.addArrangedSubview(startBotButton)
    }
    
    func setupCurrenciesView() {
        currenciesView.backgroundColor = .white
        
        leftCurrencyLabel.text = "Choose"
        leftCurrencyLabel.backgroundColor = .orange
        leftCurrencyLabel.textAlignment = .center
        leftCurrencyLabel.isUserInteractionEnabled = true
        
        rightCurrencyLabel.text = "Choose"
        rightCurrencyLabel.backgroundColor = .orange
        rightCurrencyLabel.textAlignment = .center
        rightCurrencyLabel.isUserInteractionEnabled = true
        
        currenciesView.addSubview(leftCurrencyLabel)
        currenciesView.addSubview(rightCurrencyLabel)
    }
    
    func setupCyclesInputSection() {
        cyclesTextField.placeholder = "How many operations?"
        cyclesTextField.borderStyle = .roundedRect
        
        botEnabledSwitch.isOn = true
        
        botEnabledLabel.text = "Allow the bot to work:"
    }
    
    func setupNoDataLabel() {
        noDataLabel.text = "WARNING: not enough data"
        noDataLabel.backgroundColor = .red
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
            action: #selector(handleCurrencyTapper(_:))
        )
        leftCurrencyLabel.addGestureRecognizer(gesture)
    }
    
    func setupRightCurrencyGesture() {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleCurrencyTapper(_:))
        )
        rightCurrencyLabel.addGestureRecognizer(gesture)
    }
}

// MARK: - Currency Selection
private extension BotViewController {
    @objc func handleCurrencyTapper(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        
        currentTappedLabel = tappedLabel
        if currentTappedLabel == leftCurrencyLabel {
            dataProvider.activeSide = .left
        } else if currentTappedLabel == rightCurrencyLabel {
            dataProvider.activeSide = .right
        }
        
        let vc = CompactCurrenciesViewController(dataProvider: dataProvider)
        vc.delegate = self
        
        present(vc, animated: true)
    }
}

// MARK: - Business Logic
private extension BotViewController {
    func updateResultLabelColors(finalBalance: Double, finalProfit: Double) {
        let balanceColor: UIColor = finalBalance < Constants.startBalance ? .red : .green
        let profitColor: UIColor = finalProfit < 0 ? .red : .green
        
        balanceLabel.backgroundColor = balanceColor
        profitLabel.backgroundColor = profitColor
    }
    
    @objc func handleStartBotButtonTapped() {
        guard let text = cyclesTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let cycles = Int(text),
              cycles > 0 else {
            return
        }
        
        guard botEnabledSwitch.isOn else { return }
        
        let (finalBalance, finalProfit) = stock.getFinalResult(cycles)
        
        balanceLabel.text = "Balance: \(Int(finalBalance.rounded()))"
        profitLabel.text = "Profit: \(Int(finalProfit.rounded()))"
        
        updateResultLabelColors(finalBalance: finalBalance, finalProfit: finalProfit)
        
        noDataLabel.isHidden = true
        tableView.isHidden = false
        
        operations = stock.getOperations(cycles)
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

// MARK: - UITableViewDataSource
extension BotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        operations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier) as? TableViewCell else {
            fatalError("Could not dequeue TableViewCell")
        }
        
        let operation = operations[indexPath.row]
        cell.currentOperation = operation
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - CompactCurrenciesViewControllerDelegate
extension BotViewController: CompactCurrenciesViewControllerDelegate {
    func compactCurrenciesViewController(
        didSelect currency: CurrencyCell,
        for side: SelectedSide) {
            switch side {
            case .left:
                leftCurrencyLabel.text = currency.label
            case .right:
                rightCurrencyLabel.text = currency.label
            case .none:
                break
            }
    }
}

// MARK: - Constants
private extension BotViewController {
    enum Constants {
        static let startBalance: Double = 10_000
        static let stackSpacing: CGFloat = 8
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 16
        static let sectionSpacing: CGFloat = 24
        static let imageSize: CGFloat = 48
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
