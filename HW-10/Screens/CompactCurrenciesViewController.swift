import Foundation
import UIKit

protocol CompactCurrenciesViewControllerDelegate: AnyObject {
    func compactCurrenciesViewController(
        didSelect currency: CurrencyCell,
        for side: SelectedSide
    )
}

final class CompactCurrenciesViewController: UIViewController {
    // MARK: - UI
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let filterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.filterStackViewSpacing
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let favoriteLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorite"
        label.textAlignment = .center
        label.backgroundColor = .green
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let allLabel: UILabel = {
        let label = UILabel()
        label.text = "All"
        label.textAlignment = .center
        label.backgroundColor = .lightGray
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // MARK: - Dependencies
    private let dataProvider: CurrenciesDataProvider
    
    // MARK: - Delegate
    weak var delegate: CompactCurrenciesViewControllerDelegate?
    
    // MARK: - State
    private var activeFilter: CompactFilterType = .favorite
    
    // MARK: Lifecycle
    init(dataProvider: CurrenciesDataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupCollectionView()
        setupFilterStackView()
        setupHierarchy()
        setupConstraints()
        setupFilterLabelsActive()
        applyCurrentFilters()
    }
}

// MARK: - Setup
private extension CompactCurrenciesViewController {
    func setupCollectionView() {
        collectionView.dataSource = dataProvider
        collectionView.delegate = dataProvider
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        
        dataProvider.delegate = self
        dataProvider.cellDelegate = self
    }
    
    func setupFilterStackView() {
        filterStackView.addArrangedSubview(favoriteLabel)
        filterStackView.addArrangedSubview(allLabel)
    }
    
    func setupHierarchy() {
        view.addSubview(filterStackView)
        view.addSubview(collectionView)
    }
    
    func setupFilterLabelsActive() {
        let allLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleFilterLabelTapped(_:))
        )
        allLabel.addGestureRecognizer(allLabelGesture)
        
        let favoriteLabelGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleFilterLabelTapped(_:))
        )
        favoriteLabel.addGestureRecognizer(favoriteLabelGesture)
    }
}

// MARK: - Constraints
private extension CompactCurrenciesViewController {
    func setupConstraints() {
        filterStackView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            filterStackView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.filterStackViewTopSpacing),
            filterStackView.heightAnchor.constraint(equalToConstant: Constants.filterStackViewHeight),
            filterStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor, constant: Constants.collectionViewTopSpacing),
            collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.collectionViewHorizontalInset),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.collectionViewHorizontalInset)
        ])
    }
}

// MARK: - Filter Selection
private extension CompactCurrenciesViewController {
    @objc func handleFilterLabelTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedLabel = gesture.view as? UILabel else { return }
        
        if tappedLabel == favoriteLabel {
            activeFilter = .favorite
        } else if tappedLabel == allLabel {
            activeFilter = .all
        }
        
        changeFilterType()
        applyCurrentFilters()
    }
    
    func changeFilterType() {
        switch activeFilter {
        case .favorite:
            favoriteLabel.backgroundColor = .green
            allLabel.backgroundColor = .lightGray
        case .all:
            favoriteLabel.backgroundColor = .lightGray
            allLabel.backgroundColor = .green
        }
    }
    
    func applyCurrentFilters() {
        dataProvider.applyFiltersCompact(typeFilter: activeFilter)
        collectionView.reloadData()
    }
}

// MARK: - CollectionViewCellDelegate
extension CompactCurrenciesViewController: CollectionViewCellDelegate {
    func didFavoriteTapped(in cell: CollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        dataProvider.toggleFavorite(at: indexPath.item)
        applyCurrentFilters()
    }
}

// MARK: - CurrencyDelegate
extension CompactCurrenciesViewController: CurrencyDelegate {
    func currencySelected(_ currency: CurrencyCell) {
        delegate?.compactCurrenciesViewController(
            didSelect: currency,
            for: dataProvider.activeSide
        )
    
        applyCurrentFilters()
        dismiss(animated: true)
    }
}

// MARK: - Constants
private extension CompactCurrenciesViewController {
    enum Constants {
        static let filterStackViewSpacing: CGFloat = 6
        static let filterStackViewHeight: CGFloat = 24
        static let filterStackViewTopSpacing: CGFloat = 8
        static let collectionViewTopSpacing: CGFloat = 8
        static let collectionViewHorizontalInset: CGFloat = 8
    }
}
