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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupStack()
        setupImage()
        setupSetCyclesView()
        setupButtonAction()
    }
    
    private func setupButtonAction() {
        startBotButton.addTarget(self, action: #selector(handleStartBotButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleStartBotButtonTapped() {
        guard let text = setCyclesField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let cycles = Int(text),
              cycles > 0 else {
            print("Bad Input")
            return
        }
        
        if botEnabledSwitch.isOn {
            let (finalBalance, finalProfit) = stock.getFinalResult(cycles)
            balanceLabel.text = "Balance: \(Int(finalBalance.rounded()))"
            profitLabel.text = "Profit: \(Int(finalProfit.rounded()))"
            
            handleLabelColor(finalBalance: finalBalance, finalProfit: finalProfit)
        } else {
            print("switch is off")
        }
    }
    
    private func handleLabelColor(finalBalance: Double, finalProfit: Double) {
        if finalBalance < Self.startBalance {
            balanceLabel.backgroundColor = .red
        } else {
            balanceLabel.backgroundColor = .green
        }
        
        if finalProfit < 0 {
            profitLabel.backgroundColor = .red
        } else {
            profitLabel.backgroundColor = .green
        }
    }
}

private extension ViewController {
    func setupUI() {
        view.backgroundColor = .white
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
        startBotButton.frame.size.height = 40
        startBotButton.frame.size.width = 70
        startBotButton.layer.cornerRadius = 15
        
        stackView.frame = CGRect(x: 50, y: view.bounds.height * 0.7, width: view.bounds.width / 2.7, height: view.bounds.height / 8)
        stackView.spacing = 8
        stackView.axis = .vertical
        
        stackView.addArrangedSubview(balanceLabel)
        stackView.addArrangedSubview(profitLabel)
        stackView.addArrangedSubview(startBotButton)
        view.addSubview(stackView)
    }
    
    func setupImage() {
        let image = UIImageView()
        image.frame = CGRect(x: 0, y: view.bounds.height * 0.2, width: view.bounds.width, height: view.bounds.height / 2.5)
        image.image = UIImage(named: "graph")
        
        view.addSubview(image)
    }
    
    func setupSetCyclesView() {
        setCyclesField.placeholder = "How many operations?"
        setCyclesField.borderStyle = .roundedRect
        
        let image = UIImageView()
        image.image = UIImage(named: "gpb")
        image.frame.size.width = 50
        image.frame.size.height = 50
        
        let switchView = UIView()
        
        botEnabledSwitch.isOn = true
        switchView.addSubview(botEnabledSwitch)
        
        let enableLabel = UILabel()
        enableLabel.text = "Allow the bot to work:"
        switchView.addSubview(enableLabel)
        
        let setCyclesView = UIView()
        setCyclesView.frame = CGRect(x: 50, y: view.bounds.height * 0.1, width: view.bounds.width / 3, height: view.bounds.height / 6)
        
        setCyclesField.frame = CGRect(x: 70, y: 0, width: 200, height: 50)
        switchView.frame = CGRect(x: 0, y: 60, width: 60, height: 60)
        enableLabel.frame = CGRect(x: 0, y: 0, width: 185, height: 30)
        botEnabledSwitch.frame = CGRect(x: 0, y: 30, width: 63, height: 28)
        
        setCyclesView.addSubview(switchView)
        setCyclesView.addSubview(setCyclesField)
        setCyclesView.addSubview(image)
        view.addSubview(setCyclesView)
    }
}
