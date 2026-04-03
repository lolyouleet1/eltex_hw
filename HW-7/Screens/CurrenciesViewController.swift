import UIKit
import Foundation

enum FilterType {
    case all
    case fiat
    case crypto
}

final class CurrenciesViewController: UIViewController {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let dataProvider = CurrenciesDataProvider()
    
    private let leftCurrencyLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .orange
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    private var leftCurrencyLabelIsBlinking = false
    private var leftCurrencyLabelTimer: Timer?
    private var leftCurrencyLabelIsSet = false
    private var leftCurrencyLabelChosen: String?
    
    private let rightCurrencyLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .orange
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    private var rightCurrencyLabelIsBlinking = false
    private var rightCurrencyLabelTimer: Timer?
    private var rightCurrencyLabelIsSet = false
    private var rightCurrencyLabelChosen: String?
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }()
    
    private let allLabel: UILabel = {
        let label = UILabel()
        label.text = "All"
        label.backgroundColor = .green
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let fiatLabel: UILabel = {
        let label = UILabel()
        label.text = "Fiat"
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let cryptoLabel: UILabel = {
        let label = UILabel()
        label.text = "Crypto"
        label.backgroundColor = .lightGray
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()

    private var activeFilter: FilterType = .all
    private var exchangeRateTimer: Timer?
    
    private let exchangeRateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 3
        return stackView
    }()
    
    private let exchangeRateLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate left to right:"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "Update in: 5"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    private var ticks = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubview()
        setupConstraints()
        setupLabelsTaps()
        setupExchangeRateStackView()
        startExchangeRateTimer()
    }
    
    deinit {
        exchangeRateTimer?.invalidate()
    }
}

// MARK: - Private Methods
private extension CurrenciesViewController {
    func setupUI() {
        collectionView.dataSource = dataProvider
        dataProvider.delegate = self
        collectionView.delegate = dataProvider
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
    }
    
    func addSubview() {
        view.addSubview(collectionView)
        view.addSubview(leftCurrencyLabel)
        view.addSubview(rightCurrencyLabel)
        view.addSubview(stackView)
        view.addSubview(exchangeRateStackView)
        
        stackView.addArrangedSubview(allLabel)
        stackView.addArrangedSubview(fiatLabel)
        stackView.addArrangedSubview(cryptoLabel)
        
        exchangeRateStackView.addArrangedSubview(exchangeRateLabel)
        exchangeRateStackView.addArrangedSubview(timerLabel)
    }
    
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        leftCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        rightCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        exchangeRateStackView.translatesAutoresizingMaskIntoConstraints = false
        exchangeRateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftCurrencyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            leftCurrencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftCurrencyLabel.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            leftCurrencyLabel.heightAnchor.constraint(equalToConstant: 80),
            
            rightCurrencyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rightCurrencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightCurrencyLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            rightCurrencyLabel.heightAnchor.constraint(equalToConstant: 80),
            
            stackView.topAnchor.constraint(equalTo: rightCurrencyLabel.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -10),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            
            exchangeRateStackView.topAnchor.constraint(equalTo: rightCurrencyLabel.bottomAnchor, constant: 10),
            exchangeRateStackView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -10),
            exchangeRateStackView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            exchangeRateStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
        ])
    }
    
    func setupLabelsTaps() {
        let leftCurrencyLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(leftCurrencyLabelTapped))
        leftCurrencyLabel.addGestureRecognizer(leftCurrencyLabelTapGesture)
        
        let rightCurrencyLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(rightCurrencyLabelTapped))
        rightCurrencyLabel.addGestureRecognizer(rightCurrencyLabelTapGesture)
        
        let allLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTypeLabelTapped(_:)))
        allLabel.addGestureRecognizer(allLabelTapGesture)
        
        let fiatLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTypeLabelTapped(_:)))
        fiatLabel.addGestureRecognizer(fiatLabelTapGesture)
        
        let cryptoLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTypeLabelTapped(_:)))
        cryptoLabel.addGestureRecognizer(cryptoLabelTapGesture)
    }
    
    @objc func leftCurrencyLabelTapped() {
        if leftCurrencyLabelIsBlinking || rightCurrencyLabelIsBlinking {
            return
        }
        dataProvider.activeSide = .left
        leftCurrencyLabelStartBlinking()
        leftCurrencyLabelIsSet = true
        collectionView.reloadData()
    }
    
    func leftCurrencyLabelStartBlinking() {
        leftCurrencyLabel.text = "Choose Currency"
        leftCurrencyLabel.backgroundColor = .red
        leftCurrencyLabelIsBlinking = true
        var isRedCurrencyLabel = leftCurrencyLabel.backgroundColor == .red
        
        leftCurrencyLabelTimer?.invalidate()
        
        leftCurrencyLabelTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) {
            [weak self] _ in
            guard let self else { return }
            
            if isRedCurrencyLabel {
                self.leftCurrencyLabel.backgroundColor = .blue
            } else {
                self.leftCurrencyLabel.backgroundColor = .red
            }
            
            isRedCurrencyLabel.toggle()
        }
    }
    
    func leftCurrencyLabelStopBlinking(_ currency: CurrencyCell) {
        leftCurrencyLabelTimer?.invalidate()
        leftCurrencyLabelTimer = nil
        leftCurrencyLabelIsBlinking = false
        leftCurrencyLabel.backgroundColor = .orange
        leftCurrencyLabel.text = currency.label
        leftCurrencyLabelChosen = currency.label
        
        dataProvider.activeSide = .none
    }
    
    @objc func rightCurrencyLabelTapped() {
        if rightCurrencyLabelIsBlinking || leftCurrencyLabelIsBlinking {
            return
        }
        dataProvider.activeSide = .right
        rightCurrencyLabelStartBlinking()
        rightCurrencyLabelIsSet = true
        collectionView.reloadData()
    }
    
    func rightCurrencyLabelStartBlinking() {
        rightCurrencyLabel.text = "Choose Currency"
        rightCurrencyLabel.backgroundColor = .red
        rightCurrencyLabelIsBlinking = true
        var isRedCurrencyLabel = rightCurrencyLabel.backgroundColor == .red
        
        rightCurrencyLabelTimer?.invalidate()
        
        rightCurrencyLabelTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) {
            [weak self] _ in
            guard let self else { return }
            
            if isRedCurrencyLabel {
                rightCurrencyLabel.backgroundColor = .blue
            } else {
                rightCurrencyLabel.backgroundColor = .red
            }
            
            isRedCurrencyLabel.toggle()
        }
    }
    
    func rightCurrencyLabelStopBlinking(_ currency: CurrencyCell) {
        rightCurrencyLabelTimer?.invalidate()
        rightCurrencyLabelTimer = nil
        rightCurrencyLabelIsBlinking = false
        rightCurrencyLabel.backgroundColor = .orange
        rightCurrencyLabel.text = currency.label
        rightCurrencyLabelChosen = currency.label
        
        dataProvider.activeSide = .none
    }
    
    @objc func handleTypeLabelTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        
        if tappedLabel == allLabel {
            activeFilter = .all
        } else if tappedLabel == fiatLabel {
            activeFilter = .fiat
        } else if tappedLabel == cryptoLabel {
            activeFilter = .crypto
        }
        
        handleTypeLabelColor()
    }
    
    func handleTypeLabelColor() {
        switch activeFilter {
        case .all:
            allLabel.backgroundColor = .green
            fiatLabel.backgroundColor = .lightGray
            cryptoLabel.backgroundColor = .lightGray
            
            dataProvider.applyFilter(.all)
        case .fiat:
            allLabel.backgroundColor = .lightGray
            fiatLabel.backgroundColor = .green
            cryptoLabel.backgroundColor = .lightGray
            
            dataProvider.applyFilter(.fiat)
        case .crypto:
            allLabel.backgroundColor = .lightGray
            fiatLabel.backgroundColor = .lightGray
            cryptoLabel.backgroundColor = .green
            
            dataProvider.applyFilter(.crypto)
        }
        
        collectionView.reloadData()
    }
    
    func setupExchangeRateStackView() {
        
    }
    
    func startExchangeRateTimer() {
        exchangeRateTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                 target: self,
                                                 selector: #selector(exchangeRateTimerTick),
                                                 userInfo: nil,
                                                 repeats: true)
    }
    
    @objc func exchangeRateTimerTick() {
        ticks += 1
        timerLabel.text = "Update in: \(5 - ticks)"
        
        if ticks == 5 {
            dataProvider.updateBaseValues()
            collectionView.reloadData()
            
            if let leftLabel = leftCurrencyLabelChosen,
               let rightLabel = rightCurrencyLabelChosen,
               let leftCurrencyCell = dataProvider.getCurrencyBy(label: leftLabel),
               let rightCurrencyCell = dataProvider.getCurrencyBy(label: rightLabel) {
                exchangeRateLabel.text = "Rate \(leftLabel) to \(rightLabel): \(dataProvider.exchangeRateBetween(leftCurrencyCell, rightCurrencyCell))"
            }
            
            ticks = 0
            timerLabel.text = "Update in: 5"
        }
    }
}

extension CurrenciesViewController: CurrencyDelegate {    
    func currencySelected(_ currency: CurrencyCell) {
        if leftCurrencyLabelIsBlinking {
            leftCurrencyLabelStopBlinking(currency)
        }
        if rightCurrencyLabelIsBlinking {
            rightCurrencyLabelStopBlinking(currency)
        }
    }
}
