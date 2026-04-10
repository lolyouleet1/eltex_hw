import UIKit

final class CurrenciesViewController: UIViewController {
    // MARK: - UI
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let leftCurrencyLabel = CurrenciesViewController.makeCurrencyLabel()
    private let rightCurrencyLabel = CurrenciesViewController.makeCurrencyLabel()
    
    private let filterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.stackSpacing
        return stackView
    }()
    
    private let allLabel = CurrenciesViewController.makeFilterLabel(
        text: "All",
        backgroundColor: .green
    )
    
    private let fiatLabel = CurrenciesViewController.makeFilterLabel(
        text: "Fiat",
        backgroundColor: .lightGray
    )
    
    private let cryptoLabel = CurrenciesViewController.makeFilterLabel(
        text: "Crypto",
        backgroundColor: .lightGray
    )
    
    private let exchangeRateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.exchangeRateStackSpacing
        return stackView
    }()
    
    private let exchangeRateLabel: UILabel = {
        let label = UILabel()
        label.text = "Rate left to right:"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.smallFontSize)
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "Update in: 5"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.smallFontSize)
        return label
    }()
    
    private let favoritesFilterView = FavoritesFilterView()
    
    // MARK: - Dependencies
    private let dataProvider = CurrenciesDataProvider()
    
    // MARK: - State
    private var activeFilter: FilterType = .all
    
    private var isLeftCurrencyLabelBlinking = false
    private var leftCurrencyLabelTimer: Timer?
    private var selectedLeftCurrencyLabel: String?
    
    private var isRightCurrencyLabelBlinking = false
    private var rightCurrencyLabelTimer: Timer?
    private var selectedRightCurrencyLabel: String?
    
    private var exchangeRateTimer: Timer?
    private var updateCountdown = 0
    
    private var isFavoritesOnlyEnabled = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupCollectionView()
        setupHierarchy()
        setupConstraints()
        setupCurrencyLabelGestures()
        setupFilterLabelGestures()
        startExchangeRateTimer()
    }
    
    deinit {
        exchangeRateTimer?.invalidate()
    }
}

// MARK: - Setup
private extension CurrenciesViewController {
    func setupCollectionView() {
        collectionView.dataSource = dataProvider
        collectionView.delegate = dataProvider
        collectionView.register(
            CollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionViewCell.identifier
        )
        
        dataProvider.delegate = self
        dataProvider.cellDelegate = self
        favoritesFilterView.delegate = self
    }
    
    func setupHierarchy() {
        view.addSubview(leftCurrencyLabel)
        view.addSubview(rightCurrencyLabel)
        view.addSubview(favoritesFilterView)
        view.addSubview(collectionView)
        view.addSubview(filterStackView)
        view.addSubview(exchangeRateStackView)
        
        filterStackView.addArrangedSubview(allLabel)
        filterStackView.addArrangedSubview(fiatLabel)
        filterStackView.addArrangedSubview(cryptoLabel)
        
        exchangeRateStackView.addArrangedSubview(exchangeRateLabel)
        exchangeRateStackView.addArrangedSubview(timerLabel)
    }
    
    func setupCurrencyLabelGestures() {
        let leftTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(leftCurrencyLabelTapped)
        )
        leftCurrencyLabel.addGestureRecognizer(leftTapGesture)
        
        let rightTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(rightCurrencyLabelTapped)
        )
        rightCurrencyLabel.addGestureRecognizer(rightTapGesture)
    }
    
    func setupFilterLabelGestures() {
        let allTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleFilterLabelTapped(_:))
        )
        allLabel.addGestureRecognizer(allTapGesture)
        
        let fiatTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleFilterLabelTapped(_:))
        )
        fiatLabel.addGestureRecognizer(fiatTapGesture)
        
        let cryptoTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleFilterLabelTapped(_:))
        )
        cryptoLabel.addGestureRecognizer(cryptoTapGesture)
    }
}

// MARK: - Constraints
private extension CurrenciesViewController {
    func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        leftCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        rightCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        exchangeRateStackView.translatesAutoresizingMaskIntoConstraints = false
        exchangeRateLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesFilterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftCurrencyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            leftCurrencyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftCurrencyLabel.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            leftCurrencyLabel.heightAnchor.constraint(equalToConstant: Constants.currencyLabelHeight),
            
            rightCurrencyLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            rightCurrencyLabel.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            rightCurrencyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightCurrencyLabel.heightAnchor.constraint(equalToConstant: Constants.currencyLabelHeight),
            
            favoritesFilterView.topAnchor.constraint(equalTo: rightCurrencyLabel.bottomAnchor, constant: Constants.topSpacing),
            favoritesFilterView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.collectionHorizontalInset),
            favoritesFilterView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.collectionHorizontalInset),

            filterStackView.topAnchor.constraint(equalTo: favoritesFilterView.bottomAnchor, constant: Constants.topSpacing),
            filterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterStackView.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            
            exchangeRateStackView.topAnchor.constraint(
                equalTo: favoritesFilterView.bottomAnchor,
                constant: Constants.topSpacing
            ),
            exchangeRateStackView.bottomAnchor.constraint(
                equalTo: collectionView.topAnchor,
                constant: -Constants.topSpacing
            ),
            exchangeRateStackView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            exchangeRateStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(
                equalTo: filterStackView.bottomAnchor,
                constant: Constants.collectionTopSpacing
            ),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Constants.collectionHorizontalInset
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Constants.collectionHorizontalInset
            )
        ])
    }
}

// MARK: - Currency Selection
private extension CurrenciesViewController {
    @objc func leftCurrencyLabelTapped() {
        guard !isLeftCurrencyLabelBlinking, !isRightCurrencyLabelBlinking else { return }
        
        dataProvider.activeSide = .left
        startLeftCurrencyLabelBlinking()
        collectionView.reloadData()
    }
    
    @objc func rightCurrencyLabelTapped() {
        guard !isRightCurrencyLabelBlinking, !isLeftCurrencyLabelBlinking else { return }
        
        dataProvider.activeSide = .right
        startRightCurrencyLabelBlinking()
        collectionView.reloadData()
    }
    
    func startLeftCurrencyLabelBlinking() {
        leftCurrencyLabel.text = "Choose Currency"
        leftCurrencyLabel.backgroundColor = .red
        isLeftCurrencyLabelBlinking = true
        
        var isRedCurrencyLabel = leftCurrencyLabel.backgroundColor == .red
        
        leftCurrencyLabelTimer?.invalidate()
        leftCurrencyLabelTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.blinkingInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            
            if isRedCurrencyLabel {
                self.leftCurrencyLabel.backgroundColor = .blue
            } else {
                self.leftCurrencyLabel.backgroundColor = .red
            }
            
            isRedCurrencyLabel.toggle()
        }
    }
    
    func stopLeftCurrencyLabelBlinking(with currency: CurrencyCell) {
        leftCurrencyLabelTimer?.invalidate()
        leftCurrencyLabelTimer = nil
        
        isLeftCurrencyLabelBlinking = false
        leftCurrencyLabel.backgroundColor = .orange
        leftCurrencyLabel.text = currency.label
        selectedLeftCurrencyLabel = currency.label
        
        dataProvider.activeSide = .none
    }
    
    func startRightCurrencyLabelBlinking() {
        rightCurrencyLabel.text = "Choose Currency"
        rightCurrencyLabel.backgroundColor = .red
        isRightCurrencyLabelBlinking = true
        
        var isRedCurrencyLabel = rightCurrencyLabel.backgroundColor == .red
        
        rightCurrencyLabelTimer?.invalidate()
        rightCurrencyLabelTimer = Timer.scheduledTimer(
            withTimeInterval: Constants.blinkingInterval,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }
            
            if isRedCurrencyLabel {
                self.rightCurrencyLabel.backgroundColor = .blue
            } else {
                self.rightCurrencyLabel.backgroundColor = .red
            }
            
            isRedCurrencyLabel.toggle()
        }
    }
    
    func stopRightCurrencyLabelBlinking(with currency: CurrencyCell) {
        rightCurrencyLabelTimer?.invalidate()
        rightCurrencyLabelTimer = nil
        
        isRightCurrencyLabelBlinking = false
        rightCurrencyLabel.backgroundColor = .orange
        rightCurrencyLabel.text = currency.label
        selectedRightCurrencyLabel = currency.label
        
        dataProvider.activeSide = .none
    }
}

// MARK: - Filter Handling
private extension CurrenciesViewController {
    @objc func handleFilterLabelTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        
        if tappedLabel == allLabel {
            activeFilter = .all
        } else if tappedLabel == fiatLabel {
            activeFilter = .fiat
        } else if tappedLabel == cryptoLabel {
            activeFilter = .crypto
        }
        
        updateTypeFilterUI()
        applyCurrentFilters()
    }
    
    func updateEmptyState(message: String?) {
        if let message {
            let label = UILabel()
            label.text = message
            label.textAlignment = .center
            label.textColor = .gray
            label.numberOfLines = 0
            
            collectionView.backgroundView = label
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    func applyCurrentFilters() {
        dataProvider.applyFilters(
            typeFilter: activeFilter,
            favoritesOnly: isFavoritesOnlyEnabled
        )
        
        if isFavoritesOnlyEnabled && dataProvider.isFilteredCurrenciesEmpty {
            updateEmptyState(message: "No favorite currencies")
        } else {
            updateEmptyState(message: nil)
        }
        
        collectionView.reloadData()
    }
    
    func updateTypeFilterUI() {
        switch activeFilter {
        case .all:
            allLabel.backgroundColor = .green
            fiatLabel.backgroundColor = .lightGray
            cryptoLabel.backgroundColor = .lightGray
        case .fiat:
            allLabel.backgroundColor = .lightGray
            fiatLabel.backgroundColor = .green
            cryptoLabel.backgroundColor = .lightGray
        case .crypto:
            allLabel.backgroundColor = .lightGray
            fiatLabel.backgroundColor = .lightGray
            cryptoLabel.backgroundColor = .green
        }
    }
}

// MARK: - Exchange Rate Timer
private extension CurrenciesViewController {
    func startExchangeRateTimer() {
        exchangeRateTimer = Timer.scheduledTimer(
            timeInterval: Constants.exchangeRateTimerInterval,
            target: self,
            selector: #selector(exchangeRateTimerTick),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func exchangeRateTimerTick() {
        updateCountdown += 1
        timerLabel.text = "Update in: \(Constants.exchangeRateRefreshPeriod - updateCountdown)"
        
        if updateCountdown == Constants.exchangeRateRefreshPeriod {
            dataProvider.updateBaseValues()
            applyCurrentFilters()
            
            if let leftLabel = selectedLeftCurrencyLabel,
               let rightLabel = selectedRightCurrencyLabel,
               let leftCurrencyCell = dataProvider.currency(withLabel: leftLabel),
               let rightCurrencyCell = dataProvider.currency(withLabel: rightLabel) {
                exchangeRateLabel.text = """
                Rate \(leftLabel) to \(rightLabel): \
                \(dataProvider.exchangeRateBetween(leftCurrencyCell, rightCurrencyCell))
                """
            }
            
            updateCountdown = 0
            timerLabel.text = "Update in: \(Constants.exchangeRateRefreshPeriod)"
        }
    }
}

// MARK: - Factory Methods
private extension CurrenciesViewController {
    static func makeCurrencyLabel() -> UILabel {
        let label = UILabel()
        label.text = ""
        label.backgroundColor = .orange
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.layer.borderWidth = Constants.borderWidth
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.cornerRadius = Constants.cornerRadius
        label.clipsToBounds = true
        return label
    }
    
    static func makeFilterLabel(text: String, backgroundColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.backgroundColor = backgroundColor
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }
}

// MARK: - CurrencyDelegate
extension CurrenciesViewController: CurrencyDelegate {
    func currencySelected(_ currency: CurrencyCell) {
        if isLeftCurrencyLabelBlinking {
            stopLeftCurrencyLabelBlinking(with: currency)
        } else if isRightCurrencyLabelBlinking {
            stopRightCurrencyLabelBlinking(with: currency)
        }
        
        applyCurrentFilters()
    }
}

// MARK: - CollectionViewCellDelegate
extension CurrenciesViewController: CollectionViewCellDelegate {
    func didFavoriteTapped(in cell: CollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        dataProvider.toggleFavorite(at: indexPath.item)
        applyCurrentFilters()
    }
}

// MARK: - FavoritesFilterViewDelegate
extension CurrenciesViewController: FavoritesFilterViewDelegate {
    func favoritesFilterDidChange(isOn: Bool) {
        isFavoritesOnlyEnabled = isOn
        applyCurrentFilters()
    }
}

// MARK: - Constants
private extension CurrenciesViewController {
    enum Constants {
        static let currencyLabelHeight: CGFloat = 80
        static let borderWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 10
        static let stackSpacing: CGFloat = 8
        static let exchangeRateStackSpacing: CGFloat = 3
        static let topSpacing: CGFloat = 10
        static let collectionTopSpacing: CGFloat = 20
        static let collectionHorizontalInset: CGFloat = 8
        static let blinkingInterval: TimeInterval = 0.35
        static let exchangeRateTimerInterval: TimeInterval = 1.0
        static let exchangeRateRefreshPeriod = 5
        static let smallFontSize: CGFloat = 10
    }
}
