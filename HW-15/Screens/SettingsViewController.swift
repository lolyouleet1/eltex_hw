import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func settingsViewControllerDidLogout(_ viewController: SettingsViewController)
}

final class SettingsViewController: UIViewController {
    // MARK: - UI
    private let autoLoginContainerView = UIView()
    private let autoLoginLabel = UILabel()
    private let autoLoginSwitch = UISwitch()
    private let logoutButton = UIButton(type: .system)
    
    // MARK: - Dependencies
    private let viewModel: SettingsViewModel
    
    // MARK: - Delegate
    weak var delegate: SettingsViewControllerDelegate?
    
    // MARK: - Lifecycle
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        
        setupView()
        setupNavigationItem()
        setupAutoLoginSection()
        setupLogoutButton()
        setupHierarchy()
        setupActions()
        setupConstraints()
        render(viewModel.viewState)
    }
}

// MARK: - Setup
private extension SettingsViewController {
    func setupView() {
        view.backgroundColor = Constants.backgroundColor
    }
    
    func setupNavigationItem() {
        navigationItem.title = Constants.screenTitle
        navigationController?.navigationBar.tintColor = Constants.primaryColor
    }
    
    func setupAutoLoginSection() {
        autoLoginContainerView.backgroundColor = Constants.containerBackgroundColor
        autoLoginContainerView.layer.cornerRadius = Constants.containerCornerRadius
        autoLoginContainerView.layer.borderWidth = Constants.containerBorderWidth
        autoLoginContainerView.layer.borderColor = Constants.containerBorderColor
        
        autoLoginLabel.text = Constants.autoLoginTitle
        autoLoginLabel.textColor = Constants.primaryTextColor
        autoLoginLabel.font = .systemFont(ofSize: Constants.controlFontSize, weight: .medium)
        
        autoLoginSwitch.onTintColor = Constants.primaryColor
        autoLoginSwitch.thumbTintColor = Constants.switchThumbColor
    }
    
    func setupLogoutButton() {
        logoutButton.setTitle(Constants.logoutButtonTitle, for: .normal)
        logoutButton.backgroundColor = Constants.primaryColor
        logoutButton.tintColor = Constants.buttonTintColor
        logoutButton.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        logoutButton.layer.cornerRadius = Constants.buttonCornerRadius
    }
    
    func setupHierarchy() {
        view.addSubview(autoLoginContainerView)
        view.addSubview(logoutButton)
        
        autoLoginContainerView.addSubview(autoLoginLabel)
        autoLoginContainerView.addSubview(autoLoginSwitch)
    }
    
    func setupActions() {
        autoLoginSwitch.addTarget(
            self,
            action: #selector(handleAutoLoginChanged),
            for: .valueChanged
        )
        logoutButton.addTarget(
            self,
            action: #selector(handleLogoutButtonTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Constraints
private extension SettingsViewController {
    func setupConstraints() {
        autoLoginContainerView.translatesAutoresizingMaskIntoConstraints = false
        autoLoginLabel.translatesAutoresizingMaskIntoConstraints = false
        autoLoginSwitch.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            autoLoginContainerView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.topInset),
            autoLoginContainerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            autoLoginContainerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            autoLoginContainerView.heightAnchor.constraint(equalToConstant: Constants.autoLoginContainerHeight),
            
            autoLoginLabel.leadingAnchor.constraint(equalTo: autoLoginContainerView.leadingAnchor, constant: Constants.containerContentInset),
            autoLoginLabel.centerYAnchor.constraint(equalTo: autoLoginContainerView.centerYAnchor),
            autoLoginLabel.trailingAnchor.constraint(lessThanOrEqualTo: autoLoginSwitch.leadingAnchor, constant: -Constants.containerContentInset),
            
            autoLoginSwitch.trailingAnchor.constraint(equalTo: autoLoginContainerView.trailingAnchor, constant: -Constants.containerContentInset),
            autoLoginSwitch.centerYAnchor.constraint(equalTo: autoLoginContainerView.centerYAnchor),
            
            logoutButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            logoutButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            logoutButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Constants.bottomInset),
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.logoutButtonHeight)
        ])
    }
}

// MARK: - View State
private extension SettingsViewController {
    func render(_ state: SettingsViewModel.ViewState) {
        autoLoginSwitch.isOn = state.isAutoLoginEnabled
    }
}

// MARK: - Actions
private extension SettingsViewController {
    @objc func handleAutoLoginChanged() {
        viewModel.handleAutoLoginChange(isOn: autoLoginSwitch.isOn)
    }
    
    @objc func handleLogoutButtonTapped() {
        showLogoutAlert()
    }
}

// MARK: - Alerts
private extension SettingsViewController {
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: Constants.logoutAlertTitle,
            message: Constants.logoutAlertMessage,
            preferredStyle: .alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: Constants.logoutCancelTitle,
                style: .cancel
            )
        )
        alert.addAction(
            UIAlertAction(
                title: Constants.logoutConfirmTitle,
                style: .destructive
            ) { [weak self] _ in
                guard let self else { return }
                
                viewModel.handleLogout()
                delegate?.settingsViewControllerDidLogout(self)
            }
        )
        
        present(alert, animated: true)
    }
}

// MARK: - Constants
private extension SettingsViewController {
    enum Constants {
        static let screenTitle = "Настройки"
        static let autoLoginTitle = "Автовход"
        static let logoutButtonTitle = "Выйти"
        static let logoutAlertTitle = "Выход"
        static let logoutAlertMessage = "Вы действительно хотите выйти?"
        static let logoutCancelTitle = "Отмена"
        static let logoutConfirmTitle = "Выйти"
        static let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 1.00, alpha: 1)
        static let containerBackgroundColor: UIColor = .white
        static let primaryColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let primaryTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let buttonTintColor: UIColor = .white
        static let switchThumbColor: UIColor = .white
        static let containerBorderColor = UIColor(red: 0.88, green: 0.86, blue: 0.95, alpha: 1).cgColor
        static let topInset: CGFloat = 16
        static let horizontalInset: CGFloat = 24
        static let bottomInset: CGFloat = 18
        static let containerContentInset: CGFloat = 16
        static let autoLoginContainerHeight: CGFloat = 64
        static let containerCornerRadius: CGFloat = 6
        static let containerBorderWidth: CGFloat = 1
        static let buttonCornerRadius: CGFloat = 22
        static let logoutButtonHeight: CGFloat = 44
        static let controlFontSize: CGFloat = 17
        static let buttonFontSize: CGFloat = 17
    }
}
