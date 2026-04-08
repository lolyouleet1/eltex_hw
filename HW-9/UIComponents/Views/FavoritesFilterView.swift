import UIKit

protocol FavoritesFilterViewDelegate: AnyObject {
    func favoritesFilterDidChange(isOn: Bool)
}

final class FavoritesFilterView: UIView {
    
    weak var delegate: FavoritesFilterViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Show favorites only"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let favoritesSwitch: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FavoritesFilterView {
    func setupHierarchy() {
        addSubview(titleLabel)
        addSubview(favoritesSwitch)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: centerXAnchor),
            
            favoritesSwitch.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Constants.favoritesSwitchTrailing),
            favoritesSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            topAnchor.constraint(equalTo: titleLabel.topAnchor),
            bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        ])
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

private extension FavoritesFilterView {
    enum Constants {
        static let favoritesSwitchTrailing: CGFloat = 24
    }
}
