import UIKit

final class ViewController: UIViewController {
    private let stackView = UIStackView()
    private let balanceLabel = UILabel()
    private static let startBalance: Double = 10000
    private let stock = Stock(balance: ViewController.startBalance)
    private let profitLabel = UILabel()
    private let startBotButton = UIButton(type: .system)
    private let setCyclesField = UITextField()
    private let botEnabledSwitch = UISwitch()
    private let noDataLabel = UILabel()
    private let switchView = UIView()
    private let enableLabel = UILabel()
    private let setCyclesView = UIView()
    private let gpbImage = UIImageView()
    private let tableView = UITableView()
    
    private var operations: [Operation] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubview()
        setupStack()
        setupSetCyclesView()
        setupButtonAction()
        setupNoDataLabel()
        setupConstraints()
    }
}

// MARK: - Private Methods
private extension ViewController {
    func setupUI() {
        view.backgroundColor = .white
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.identifier)
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    func addSubview() {
        view.addSubview(stackView)
        view.addSubview(setCyclesView)
        view.addSubview(noDataLabel)
        view.addSubview(tableView)
        switchView.addSubview(botEnabledSwitch)
        switchView.addSubview(enableLabel)
    }
    
    func setupButtonAction() {
        startBotButton.addTarget(self, action: #selector(handleStartBotButtonTapped), for: .touchUpInside)
    }
    
    func setupStack() {
        balanceLabel.text = "Balance: \(stock.balance)"
        balanceLabel.backgroundColor = .gray
        balanceLabel.textColor = .black
        
        profitLabel.text = "Profit: 0"
        profitLabel.backgroundColor = .gray
        profitLabel.textColor = .black
        
        startBotButton.setTitle("START BOT", for: .normal)
        startBotButton.backgroundColor = .purple
        startBotButton.tintColor = .white
        startBotButton.layer.cornerRadius = 15
        
        stackView.spacing = 8
        stackView.axis = .vertical
        
        stackView.addArrangedSubview(balanceLabel)
        stackView.addArrangedSubview(profitLabel)
        stackView.addArrangedSubview(startBotButton)
    }
    
    func setupSetCyclesView() {
        setCyclesField.placeholder = "How many operations?"
        setCyclesField.borderStyle = .roundedRect
        
        gpbImage.image = UIImage(named: "gpb")
        
        botEnabledSwitch.isOn = true
        
        enableLabel.text = "Allow the bot to work:"
        
        setCyclesView.addSubview(switchView)
        setCyclesView.addSubview(setCyclesField)
        setCyclesView.addSubview(gpbImage)
    }
    
    func handleLabelColor(finalBalance: Double, finalProfit: Double) {
        let balanceColor: UIColor = finalBalance < Self.startBalance ? .red : .green
        let profitColor: UIColor = finalProfit < 0 ? .red : .green

        balanceLabel.backgroundColor = balanceColor
        profitLabel.backgroundColor = profitColor
    }
    
    @objc func handleStartBotButtonTapped() {
        guard let text = setCyclesField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let cycles = Int(text),
              cycles > 0 else {
            return
        }
        
        if botEnabledSwitch.isOn {
            let (finalBalance, finalProfit) = stock.getFinalResult(cycles)
            balanceLabel.text = "Balance: \(Int(finalBalance.rounded()))"
            profitLabel.text = "Profit: \(Int(finalProfit.rounded()))"
            
            handleLabelColor(finalBalance: finalBalance, finalProfit: finalProfit)
            
            noDataLabel.isHidden = true
            tableView.isHidden = false
            
            operations = stock.getOperations(cycles)
        }
    }
    
    func setupNoDataLabel() {
        noDataLabel.text = "WARNING: not enough data"
        noDataLabel.backgroundColor = .red
    }
    
    enum Layout {
            static let horizontalInset: CGFloat = 16
            static let topInset: CGFloat = 16
            static let sectionSpacing: CGFloat = 24

            static let imageSize: CGFloat = 48
            static let imageToFieldSpacing: CGFloat = 16

            static let switchSectionTopSpacing: CGFloat = 16
            static let switchTopSpacing: CGFloat = 8
    }
    
    func setupConstraints() {
            noDataLabel.translatesAutoresizingMaskIntoConstraints = false
            switchView.translatesAutoresizingMaskIntoConstraints = false
            setCyclesField.translatesAutoresizingMaskIntoConstraints = false
            enableLabel.translatesAutoresizingMaskIntoConstraints = false
            botEnabledSwitch.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            setCyclesView.translatesAutoresizingMaskIntoConstraints = false
            gpbImage.translatesAutoresizingMaskIntoConstraints = false
            tableView.translatesAutoresizingMaskIntoConstraints = false

            let guide = view.safeAreaLayoutGuide

            NSLayoutConstraint.activate([
                // MARK: - noDataLabel
                noDataLabel.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
                noDataLabel.centerYAnchor.constraint(equalTo: guide.centerYAnchor),

                // MARK: - setCyclesView
                setCyclesView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Layout.topInset),
                setCyclesView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Layout.horizontalInset),
                setCyclesView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Layout.horizontalInset),

                // MARK: - gpbImage
                gpbImage.topAnchor.constraint(equalTo: setCyclesView.topAnchor),
                gpbImage.leadingAnchor.constraint(equalTo: setCyclesView.leadingAnchor),
                gpbImage.widthAnchor.constraint(equalToConstant: Layout.imageSize),
                gpbImage.heightAnchor.constraint(equalToConstant: Layout.imageSize),

                // MARK: - setCyclesField
                setCyclesField.leadingAnchor.constraint(equalTo: gpbImage.trailingAnchor, constant: Layout.imageToFieldSpacing),
                setCyclesField.trailingAnchor.constraint(equalTo: setCyclesView.trailingAnchor),
                setCyclesField.centerYAnchor.constraint(equalTo: gpbImage.centerYAnchor),

                // MARK: - switchView
                switchView.topAnchor.constraint(equalTo: gpbImage.bottomAnchor, constant: Layout.switchSectionTopSpacing),
                switchView.leadingAnchor.constraint(equalTo: setCyclesView.leadingAnchor),
                switchView.trailingAnchor.constraint(equalTo: setCyclesView.trailingAnchor),
                switchView.bottomAnchor.constraint(equalTo: setCyclesView.bottomAnchor),

                // MARK: - enableLabel
                enableLabel.topAnchor.constraint(equalTo: switchView.topAnchor),
                enableLabel.leadingAnchor.constraint(equalTo: switchView.leadingAnchor),
                enableLabel.trailingAnchor.constraint(lessThanOrEqualTo: switchView.trailingAnchor),

                // MARK: - botEnabledSwitch
                botEnabledSwitch.topAnchor.constraint(equalTo: enableLabel.bottomAnchor, constant: Layout.switchTopSpacing),
                botEnabledSwitch.leadingAnchor.constraint(equalTo: switchView.leadingAnchor),
                botEnabledSwitch.bottomAnchor.constraint(equalTo: switchView.bottomAnchor),

                // MARK: - stackView
                stackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Layout.horizontalInset),
                stackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Layout.horizontalInset),
                stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Layout.topInset),

                // MARK: - tableView
                tableView.topAnchor.constraint(equalTo: setCyclesView.bottomAnchor, constant: Layout.sectionSpacing),
                tableView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 8),
                tableView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -8),
                tableView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -Layout.sectionSpacing)
        ])
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return operations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier),
           let tableViewCell = cell as? TableViewCell {
            let operation = operations[indexPath.row]
            tableViewCell.currentOperation = operation
            tableViewCell.selectionStyle = .none
            return tableViewCell
        }
        return UITableViewCell()
    }
}
