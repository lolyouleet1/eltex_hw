import UIKit

protocol FavoritesFilterViewDelegate: AnyObject {
    func favoritesFilterDidChange(isOn: Bool)
}

final class FavoritesFilterView: UIView {
    // MARK: - Delegate
    weak var delegate: FavoritesFilterViewDelegate?
    
    // MARK: - Properties
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.titleText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoritesSwitch: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        setupHierarchy()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

// MARK: - Private Methods
private extension FavoritesFilterView {
    func setupHierarchy() {
        addSubview(titleLabel)
        addSubview(favoritesSwitch)
    }
    
    func setupActions() {
        favoritesSwitch.addTarget(
            self,
            action: #selector(handleSwitchValueChanged),
            for: .valueChanged
        )
    }
    
    @objc func handleSwitchValueChanged() {
        delegate?.favoritesFilterDidChange(isOn: favoritesSwitch.isOn)
    }
}

// MARK: - Constraints
private extension FavoritesFilterView {
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: centerXAnchor),
            
            favoritesSwitch.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor,
                constant: Constants.favoritesSwitchTrailing
            ),
            favoritesSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            topAnchor.constraint(equalTo: titleLabel.topAnchor),
            bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        ])
    }
}

// MARK: - Constants
private extension FavoritesFilterView {
    enum Constants {
        static let titleText = "Show favorites only"
        static let favoritesSwitchTrailing: CGFloat = 24
    }
}
