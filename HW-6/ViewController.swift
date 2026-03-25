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
    private let tableView = TradeHistoryController()
    private var decisionsArray: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupStack()
        setupSetCyclesView()
        setupButtonAction()
        setupNoDataLabel()
        setupConstraints()
    }
}

// MARK: - Private Methods
private extension ViewController {
    func setupConstraints() {
        noDataLabel.translatesAutoresizingMaskIntoConstraints = false
        switchView.translatesAutoresizingMaskIntoConstraints = false
        setCyclesField.translatesAutoresizingMaskIntoConstraints = false
        enableLabel.translatesAutoresizingMaskIntoConstraints = false
        botEnabledSwitch.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        startBotButton.translatesAutoresizingMaskIntoConstraints = false
        setCyclesView.translatesAutoresizingMaskIntoConstraints = false
        gpbImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // MARK: - noDataLabel constraints
            NSLayoutConstraint(item: noDataLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: noDataLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
        
            // MARK: - setCyclesView constraints and its contents
            NSLayoutConstraint(item: setCyclesView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 48),
            setCyclesView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.1),
            NSLayoutConstraint(item: setCyclesView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.3, constant: 0),
            NSLayoutConstraint(item: setCyclesView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.16, constant: 0),
            
            NSLayoutConstraint(item: setCyclesField, attribute: .leading, relatedBy: .equal, toItem: setCyclesView, attribute: .leading, multiplier: 1, constant: 64),
            
            NSLayoutConstraint(item: gpbImage, attribute: .leading, relatedBy: .equal, toItem: setCyclesView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: gpbImage, attribute: .top, relatedBy: .equal, toItem: setCyclesView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: gpbImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 48),
            NSLayoutConstraint(item: gpbImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 48),
            
            NSLayoutConstraint(item: switchView, attribute: .top, relatedBy: .equal, toItem: setCyclesView, attribute: .top, multiplier: 1, constant: 64),
            NSLayoutConstraint(item: switchView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 64),
            NSLayoutConstraint(item: switchView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 64),
            
            NSLayoutConstraint(item: enableLabel, attribute: .leading, relatedBy: .equal, toItem: switchView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: enableLabel, attribute: .top, relatedBy: .equal, toItem: switchView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: enableLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 185),
            NSLayoutConstraint(item: enableLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 30),
            
            NSLayoutConstraint(item: botEnabledSwitch, attribute: .leading, relatedBy: .equal, toItem: switchView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: botEnabledSwitch, attribute: .top, relatedBy: .equal, toItem: switchView, attribute: .top, multiplier: 1, constant: 32),

            // MARK: - stackView constraints
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.bounds.height * 0.7),
            NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 48),
            NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.37, constant: 0),
            NSLayoutConstraint(item: stackView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.125, constant: 0)
        ])
    }
    
    func setupUI() {
        view.backgroundColor = .white
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
        view.addSubview(stackView)
    }
    
    func setupSetCyclesView() {
        setCyclesField.placeholder = "How many operations?"
        setCyclesField.borderStyle = .roundedRect
        
        gpbImage.image = UIImage(named: "gpb")
        
        botEnabledSwitch.isOn = true
        switchView.addSubview(botEnabledSwitch)
        
        enableLabel.text = "Allow the bot to work:"
        switchView.addSubview(enableLabel)
        
        setCyclesView.addSubview(switchView)
        setCyclesView.addSubview(setCyclesField)
        setCyclesView.addSubview(gpbImage)
        view.addSubview(setCyclesView)
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
            
            decisionsArray = stock.getOperations(cycles)
        }
        print(decisionsArray)
    }
    
    func setupNoDataLabel() {
        noDataLabel.text = "WARNING: not enought data"
        noDataLabel.backgroundColor = .red
        
        view.addSubview(noDataLabel)
    }
}
