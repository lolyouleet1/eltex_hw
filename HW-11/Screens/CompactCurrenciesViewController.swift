import UIKit

protocol CompactCurrenciesViewControllerDelegate: AnyObject {
    func compactCurrenciesViewController(didSelect currency: Currency, for side: SelectedSide)
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
        label.text = Constants.favoriteFilterTitle
        label.textAlignment = .center
        label.backgroundColor = Constants.activeFilterColor
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let allLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.allFilterTitle
        label.textAlignment = .center
        label.backgroundColor = Constants.inactiveFilterColor
        label.isUserInteractionEnabled = true
        return label
    }()
    
    // MARK: - Dependencies
    private let viewModel: CompactCurrenciesViewModel
    
    // MARK: - Delegate
    weak var delegate: CompactCurrenciesViewControllerDelegate?
    
    // MARK: - Lifecycle
    init(viewModel: CompactCurrenciesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.backgroundColor
        
        setupCollectionView()
        setupFilterStackView()
        setupHierarchy()
        setupConstraints()
        setupFilterLabelsActive()
        render(viewModel.viewState)
    }
}

// MARK: - Setup
private extension CompactCurrenciesViewController {
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionViewCell.identifier
        )
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
            viewModel.handleFilterSelection(.favorite)
        } else if tappedLabel == allLabel {
            viewModel.handleFilterSelection(.all)
        }
        
        render(viewModel.viewState)
    }
    
    func render(_ state: CompactCurrenciesViewModel.ViewState) {
        switch state.activeFilter {
        case .favorite:
            favoriteLabel.backgroundColor = Constants.activeFilterColor
            allLabel.backgroundColor = Constants.inactiveFilterColor
        case .all:
            favoriteLabel.backgroundColor = Constants.inactiveFilterColor
            allLabel.backgroundColor = Constants.activeFilterColor
        }
        
        collectionView.reloadData()
    }
}

// MARK: - CollectionViewCellDelegate
extension CompactCurrenciesViewController: CollectionViewCellDelegate {
    func didFavoriteTapped(in cell: CollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        viewModel.handleFavoriteToggle(at: indexPath.item)
        render(viewModel.viewState)
    }
}

// MARK: - UICollectionViewDataSource
extension CompactCurrenciesViewController: UICollectionViewDataSource {
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
extension CompactCurrenciesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currency = viewModel.handleCurrencySelection(at: indexPath.item) else { return }
        
        delegate?.compactCurrenciesViewController(
            didSelect: currency,
            for: viewModel.selectionSide
        )
        
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CompactCurrenciesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: Constants.itemWidth, height: Constants.itemHeight)
    }
}

// MARK: - Constants
private extension CompactCurrenciesViewController {
    enum Constants {
        static let favoriteFilterTitle = "Favorite"
        static let allFilterTitle = "All"
        static let backgroundColor: UIColor = .white
        static let activeFilterColor: UIColor = .green
        static let inactiveFilterColor: UIColor = .lightGray
        static let filterStackViewSpacing: CGFloat = 6
        static let filterStackViewHeight: CGFloat = 24
        static let filterStackViewTopSpacing: CGFloat = 8
        static let collectionViewTopSpacing: CGFloat = 8
        static let collectionViewHorizontalInset: CGFloat = 8
        static let itemWidth: CGFloat = 72
        static let itemHeight: CGFloat = 44
    }
}
