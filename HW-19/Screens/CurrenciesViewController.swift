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
        text: Constants.allFilterTitle,
        backgroundColor: Constants.activeFilterColor
    )
    
    private let fiatLabel = CurrenciesViewController.makeFilterLabel(
        text: Constants.fiatFilterTitle,
        backgroundColor: Constants.inactiveFilterColor
    )
    
    private let cryptoLabel = CurrenciesViewController.makeFilterLabel(
        text: Constants.cryptoFilterTitle,
        backgroundColor: Constants.inactiveFilterColor
    )
    
    private let exchangeRateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.exchangeRateStackSpacing
        return stackView
    }()
    
    private let exchangeRateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.smallFontSize)
        return label
    }()
    
    private let timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.smallFontSize)
        return label
    }()
    
    private let favoritesFilterView = FavoritesFilterView()
    
    // MARK: - Dependencies
    private let viewModel: CurrenciesViewModel
    
    // MARK: - Lifecycle
    init(viewModel: CurrenciesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.backgroundColor
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        
        setupCollectionView()
        setupHierarchy()
        setupConstraints()
        setupCurrencyLabelGestures()
        setupFilterLabelGestures()
        viewModel.start()
    }
    
    deinit {
        viewModel.onStateChange = nil
        viewModel.stop()
    }
}

// MARK: - Setup
private extension CurrenciesViewController {
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionViewCell.identifier
        )
        
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
        viewModel.handleCurrencyLabelTap(.left)
    }
    
    @objc func rightCurrencyLabelTapped() {
        viewModel.handleCurrencyLabelTap(.right)
    }
}

// MARK: - Filter Handling
private extension CurrenciesViewController {
    @objc func handleFilterLabelTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        
        if tappedLabel == allLabel {
            viewModel.handleFilterSelection(.all)
        } else if tappedLabel == fiatLabel {
            viewModel.handleFilterSelection(.fiat)
        } else if tappedLabel == cryptoLabel {
            viewModel.handleFilterSelection(.crypto)
        }
    }
    
    func updateEmptyState(message: String?) {
        if let message {
            let label = UILabel()
            label.text = message
            label.textAlignment = .center
            label.textColor = Constants.emptyStateTextColor
            label.numberOfLines = 0
            
            collectionView.backgroundView = label
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    func render(_ state: CurrenciesViewModel.ViewState) {
        apply(labelState: state.leftLabelState, to: leftCurrencyLabel)
        apply(labelState: state.rightLabelState, to: rightCurrencyLabel)
        
        exchangeRateLabel.text = state.exchangeRateText
        timerLabel.text = state.timerText
        
        switch state.activeFilter {
        case .all:
            allLabel.backgroundColor = Constants.activeFilterColor
            fiatLabel.backgroundColor = Constants.inactiveFilterColor
            cryptoLabel.backgroundColor = Constants.inactiveFilterColor
        case .fiat:
            allLabel.backgroundColor = Constants.inactiveFilterColor
            fiatLabel.backgroundColor = Constants.activeFilterColor
            cryptoLabel.backgroundColor = Constants.inactiveFilterColor
        case .crypto:
            allLabel.backgroundColor = Constants.inactiveFilterColor
            fiatLabel.backgroundColor = Constants.inactiveFilterColor
            cryptoLabel.backgroundColor = Constants.activeFilterColor
        }
        
        updateEmptyState(message: state.emptyStateMessage)
        collectionView.reloadData()
    }
}

// MARK: - Label Appearance
private extension CurrenciesViewController {
    func apply(labelState: CurrenciesViewModel.LabelState, to label: UILabel) {
        label.text = labelState.text
        
        switch labelState.appearance {
        case .normal:
            label.backgroundColor = Constants.defaultCurrencyLabelColor
        case .attentionPrimary:
            label.backgroundColor = Constants.primaryAttentionColor
        case .attentionSecondary:
            label.backgroundColor = Constants.secondaryAttentionColor
        }
    }
}

// MARK: - Factory Methods
private extension CurrenciesViewController {
    static func makeCurrencyLabel() -> UILabel {
        let label = UILabel()
        label.text = nil
        label.backgroundColor = Constants.defaultCurrencyLabelColor
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.layer.borderWidth = Constants.borderWidth
        label.layer.borderColor = Constants.currencyLabelBorderColor
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

// MARK: - UICollectionViewDataSource
extension CurrenciesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.viewState.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.identifier,
            for: indexPath
        ) as? CollectionViewCell else {
            return UICollectionViewCell(frame: .zero)
        }
        
        cell.configure(with: viewModel.viewState.items[indexPath.item])
        cell.delegate = self
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CurrenciesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.handleCurrencySelection(at: indexPath.item)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CurrenciesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: Constants.itemWidth, height: Constants.itemHeight)
    }
}

// MARK: - CollectionViewCellDelegate
extension CurrenciesViewController: CollectionViewCellDelegate {
    func didFavoriteTapped(in cell: CollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        viewModel.handleFavoriteToggle(at: indexPath.item)
    }
}

// MARK: - FavoritesFilterViewDelegate
extension CurrenciesViewController: FavoritesFilterViewDelegate {
    func favoritesFilterDidChange(isOn: Bool) {
        viewModel.handleFavoritesToggle(isOn: isOn)
    }
}

// MARK: - Constants
private extension CurrenciesViewController {
    enum Constants {
        static let allFilterTitle = "All"
        static let fiatFilterTitle = "Fiat"
        static let cryptoFilterTitle = "Crypto"
        static let backgroundColor: UIColor = .white
        static let activeFilterColor: UIColor = .green
        static let inactiveFilterColor: UIColor = .lightGray
        static let defaultCurrencyLabelColor: UIColor = .orange
        static let primaryAttentionColor: UIColor = .red
        static let secondaryAttentionColor: UIColor = .blue
        static let emptyStateTextColor: UIColor = .gray
        static let currencyLabelBorderColor: CGColor = UIColor.black.cgColor
        static let currencyLabelHeight: CGFloat = 80
        static let borderWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 10
        static let stackSpacing: CGFloat = 8
        static let exchangeRateStackSpacing: CGFloat = 3
        static let topSpacing: CGFloat = 10
        static let collectionTopSpacing: CGFloat = 20
        static let collectionHorizontalInset: CGFloat = 8
        static let smallFontSize: CGFloat = 10
        static let itemWidth: CGFloat = 72
        static let itemHeight: CGFloat = 44
    }
}
