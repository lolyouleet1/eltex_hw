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
        label.font = .systemFont(ofSize: Constants.filterFontSize, weight: .medium)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let allLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.allFilterTitle
        label.textAlignment = .center
        label.font = .systemFont(ofSize: Constants.filterFontSize, weight: .medium)
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
        collectionView.backgroundColor = Constants.clearColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(
            CollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionViewCell.identifier
        )
    }
    
    func setupFilterStackView() {
        filterStackView.backgroundColor = Constants.filterStackViewBackgroundColor
        filterStackView.layer.cornerRadius = Constants.filterStackViewCornerRadius
        filterStackView.clipsToBounds = true
        
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
            filterStackView.widthAnchor.constraint(equalToConstant: Constants.filterStackViewWidth),
            
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
            applyActiveFilterAppearance(to: favoriteLabel)
            applyInactiveFilterAppearance(to: allLabel)
        case .all:
            applyInactiveFilterAppearance(to: favoriteLabel)
            applyActiveFilterAppearance(to: allLabel)
        }
        
        collectionView.reloadData()
    }
    
    func applyActiveFilterAppearance(to label: UILabel) {
        label.backgroundColor = Constants.activeFilterColor
        label.textColor = Constants.activeFilterTextColor
    }
    
    func applyInactiveFilterAppearance(to label: UILabel) {
        label.backgroundColor = Constants.inactiveFilterColor
        label.textColor = Constants.inactiveFilterTextColor
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
        
        cell.configureCompact(with: viewModel.viewState.items[indexPath.item])
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
        
        render(viewModel.viewState)
        
        DispatchQueue.main.async {
            if let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
                cell.animateSelection()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CompactCurrenciesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: Constants.itemWidth, height: Constants.itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.collectionViewLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        Constants.collectionViewItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(
            top: Constants.collectionViewSectionTopInset,
            left: .zero,
            bottom: Constants.collectionViewSectionBottomInset,
            right: .zero
        )
    }
}

// MARK: - Constants
private extension CompactCurrenciesViewController {
    enum Constants {
        static let favoriteFilterTitle = "Favorite"
        static let allFilterTitle = "All"
        static let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 1.00, alpha: 1)
        static let activeFilterColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let inactiveFilterColor = UIColor(red: 0.96, green: 0.95, blue: 1.00, alpha: 1)
        static let activeFilterTextColor: UIColor = .white
        static let inactiveFilterTextColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let clearColor: UIColor = .clear
        static let filterStackViewBackgroundColor = UIColor(red: 0.96, green: 0.95, blue: 1.00, alpha: 1)
        static let filterStackViewSpacing: CGFloat = .zero
        static let filterStackViewWidth: CGFloat = 186
        static let filterStackViewHeight: CGFloat = 28
        static let filterStackViewTopSpacing: CGFloat = 42
        static let filterStackViewCornerRadius: CGFloat = 4
        static let filterFontSize: CGFloat = 12
        static let collectionViewTopSpacing: CGFloat = 14
        static let collectionViewHorizontalInset: CGFloat = 14
        static let collectionViewLineSpacing: CGFloat = 10
        static let collectionViewItemSpacing: CGFloat = 10
        static let collectionViewSectionTopInset: CGFloat = .zero
        static let collectionViewSectionBottomInset: CGFloat = 20
        static let itemWidth: CGFloat = 72
        static let itemHeight: CGFloat = 44
    }
}
