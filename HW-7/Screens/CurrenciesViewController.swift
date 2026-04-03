import UIKit
import Foundation

final class CurrenciesViewController: UIViewController {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let dataProvider = CurrenciesDataProvider()
    
    private let leftCurrencyLabel: UILabel = {
        let label = UILabel()
        label.text = "LEFT"
        label.backgroundColor = .orange
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    private var leftCurrencyLabelIsBlinking = false
    private var leftCurrencyLabelTimer: Timer?
    
    private let rightCurrencyLabel: UILabel = {
        let label = UILabel()
        label.text = "RIGHT"
        label.backgroundColor = .orange
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    private var rightCurrencyLabelIsBlinking = false
    private var rightCurrencyLabelTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        addSubview()
        setupConstraints()
        setupLabelsTaps()
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
    }
    
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        leftCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        rightCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leftCurrencyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            leftCurrencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftCurrencyLabel.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            leftCurrencyLabel.heightAnchor.constraint(equalToConstant: 80),
            
            rightCurrencyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rightCurrencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightCurrencyLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            rightCurrencyLabel.heightAnchor.constraint(equalToConstant: 80),
            
            collectionView.topAnchor.constraint(equalTo: rightCurrencyLabel.bottomAnchor, constant: 20),
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
    }
    
    @objc func leftCurrencyLabelTapped() {
        if leftCurrencyLabelIsBlinking || rightCurrencyLabelIsBlinking {
            return
        }
        dataProvider.activeSide = .left
        leftCurrencyLabelStartBlinking()
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
        
        dataProvider.activeSide = .none
    }
    
    @objc func rightCurrencyLabelTapped() {
        if rightCurrencyLabelIsBlinking || leftCurrencyLabelIsBlinking {
            return
        }
        dataProvider.activeSide = .right
        rightCurrencyLabelStartBlinking()
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
        
        dataProvider.activeSide = .none
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
