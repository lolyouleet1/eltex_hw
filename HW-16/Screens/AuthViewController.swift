import Combine
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewControllerDidAuthorize(_ viewController: AuthViewController)
}

final class AuthViewController: UIViewController {
    // MARK: - UI
    private let textFieldsStackView = UIStackView()
    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let forwardButton = UIButton(type: .system)
    private let modeSegmentedControl = UISegmentedControl(
        items: [
            Constants.loginModeTitle,
            Constants.registrationModeTitle
        ]
    )
    
    // MARK: - Dependencies
    private let viewModel: AuthViewModel
    
    // MARK: - Delegate
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - State
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTextFields()
        setupForwardButton()
        setupModeSegmentedControl()
        setupHierarchy()
        setupActions()
        setupConstraints()
        bindViewModel()
    }
}

// MARK: - Setup
private extension AuthViewController {
    func bindViewModel() {
        viewModel.viewStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
        
        makeTextFieldTextPublisher(loginTextField)
            .sink { [weak self] text in
                self?.viewModel.handleLoginChange(text)
            }
            .store(in: &cancellables)
        
        makeTextFieldTextPublisher(passwordTextField)
            .sink { [weak self] text in
                self?.viewModel.handlePasswordChange(text)
            }
            .store(in: &cancellables)
    }
    
    func setupView() {
        view.backgroundColor = Constants.backgroundColor
    }
    
    func setupTextFields() {
        textFieldsStackView.axis = .vertical
        textFieldsStackView.spacing = Constants.textFieldsStackSpacing
        
        configureTextField(
            loginTextField,
            placeholder: Constants.loginPlaceholder,
            isSecureTextEntry: false
        )
        loginTextField.textContentType = .username
        
        configureTextField(
            passwordTextField,
            placeholder: Constants.passwordPlaceholder,
            isSecureTextEntry: true
        )
        passwordTextField.textContentType = .password
    }
    
    func setupForwardButton() {
        forwardButton.setTitle(Constants.forwardButtonTitle, for: .normal)
        forwardButton.backgroundColor = Constants.primaryColor
        forwardButton.tintColor = Constants.buttonTintColor
        forwardButton.titleLabel?.font = .systemFont(ofSize: Constants.buttonFontSize, weight: .medium)
        forwardButton.layer.cornerRadius = Constants.buttonCornerRadius
    }
    
    func setupModeSegmentedControl() {
        modeSegmentedControl.selectedSegmentIndex = Constants.loginSegmentIndex
        modeSegmentedControl.selectedSegmentTintColor = Constants.primaryColor
        modeSegmentedControl.backgroundColor = Constants.segmentedControlBackgroundColor
        modeSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: Constants.segmentedControlSelectedTextColor
            ],
            for: .selected
        )
        modeSegmentedControl.setTitleTextAttributes(
            [
                .foregroundColor: Constants.segmentedControlTextColor
            ],
            for: .normal
        )
    }
    
    func setupHierarchy() {
        view.addSubview(textFieldsStackView)
        view.addSubview(forwardButton)
        view.addSubview(modeSegmentedControl)
        
        textFieldsStackView.addArrangedSubview(loginTextField)
        textFieldsStackView.addArrangedSubview(passwordTextField)
    }
    
    func setupActions() {
        forwardButton.addTarget(
            self,
            action: #selector(handleForwardButtonTapped),
            for: .touchUpInside
        )
        modeSegmentedControl.addTarget(
            self,
            action: #selector(handleModeChanged),
            for: .valueChanged
        )
    }
    
    func configureTextField(_ textField: UITextField, placeholder: String, isSecureTextEntry: Bool) {
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = Constants.textFieldBackgroundColor
        textField.textColor = Constants.primaryTextColor
        textField.font = .systemFont(ofSize: Constants.textFieldFontSize)
        textField.layer.cornerRadius = Constants.textFieldCornerRadius
        textField.layer.borderWidth = Constants.textFieldBorderWidth
        textField.layer.borderColor = Constants.textFieldBorderColor
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = isSecureTextEntry
        textField.leftView = UIView(
            frame: CGRect(
                x: .zero,
                y: .zero,
                width: Constants.textFieldHorizontalPadding,
                height: Constants.textFieldHeight
            )
        )
        textField.leftViewMode = .always
    }
    
    func makeTextFieldTextPublisher(_ textField: UITextField) -> AnyPublisher<String?, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: textField
        )
        .map { notification in
            (notification.object as? UITextField)?.text
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Constraints
private extension AuthViewController {
    func setupConstraints() {
        textFieldsStackView.translatesAutoresizingMaskIntoConstraints = false
        loginTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        modeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            textFieldsStackView.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            textFieldsStackView.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            textFieldsStackView.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: Constants.textFieldsVerticalOffset),
            
            loginTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            passwordTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            forwardButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            forwardButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            forwardButton.bottomAnchor.constraint(equalTo: modeSegmentedControl.topAnchor, constant: -Constants.controlsSpacing),
            forwardButton.heightAnchor.constraint(equalToConstant: Constants.forwardButtonHeight),
            
            modeSegmentedControl.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: Constants.horizontalInset),
            modeSegmentedControl.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -Constants.horizontalInset),
            modeSegmentedControl.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -Constants.bottomInset),
            modeSegmentedControl.heightAnchor.constraint(equalToConstant: Constants.segmentedControlHeight)
        ])
    }
}

// MARK: - View State
private extension AuthViewController {
    func render(_ state: AuthViewModel.ViewState) {
        forwardButton.isEnabled = state.isForwardButtonEnabled
        forwardButton.alpha = state.isForwardButtonEnabled ? Constants.enabledAlpha : Constants.disabledAlpha
        
        switch state.mode {
        case .login:
            modeSegmentedControl.selectedSegmentIndex = Constants.loginSegmentIndex
        case .registration:
            modeSegmentedControl.selectedSegmentIndex = Constants.registrationSegmentIndex
        }
    }
}

// MARK: - Actions
private extension AuthViewController {
    @objc func handleForwardButtonTapped() {
        guard viewModel.handleForwardButtonTapped() else { return }
        
        delegate?.authViewControllerDidAuthorize(self)
    }
    
    @objc func handleModeChanged() {
        let mode: AuthViewModel.AuthMode
        
        if modeSegmentedControl.selectedSegmentIndex == Constants.registrationSegmentIndex {
            mode = .registration
        } else {
            mode = .login
        }
        
        viewModel.handleModeSelection(mode)
    }
}

// MARK: - Constants
private extension AuthViewController {
    enum Constants {
        static let loginPlaceholder = "Логин"
        static let passwordPlaceholder = "Пароль"
        static let forwardButtonTitle = "Вперед"
        static let loginModeTitle = "Вход"
        static let registrationModeTitle = "Регистрация"
        static let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 1.00, alpha: 1)
        static let primaryColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let primaryTextColor = UIColor(red: 0.19, green: 0.20, blue: 0.40, alpha: 1)
        static let buttonTintColor: UIColor = .white
        static let textFieldBackgroundColor: UIColor = .white
        static let textFieldBorderColor = UIColor(red: 0.86, green: 0.85, blue: 0.92, alpha: 1).cgColor
        static let segmentedControlBackgroundColor = UIColor(red: 0.96, green: 0.95, blue: 1.00, alpha: 1)
        static let segmentedControlTextColor = UIColor(red: 0.31, green: 0.23, blue: 0.78, alpha: 1)
        static let segmentedControlSelectedTextColor: UIColor = .white
        static let horizontalInset: CGFloat = 24
        static let bottomInset: CGFloat = 18
        static let controlsSpacing: CGFloat = 12
        static let textFieldsStackSpacing: CGFloat = 12
        static let textFieldsVerticalOffset: CGFloat = -80
        static let textFieldHeight: CGFloat = 44
        static let textFieldCornerRadius: CGFloat = 4
        static let textFieldBorderWidth: CGFloat = 1
        static let textFieldHorizontalPadding: CGFloat = 14
        static let textFieldFontSize: CGFloat = 17
        static let buttonFontSize: CGFloat = 17
        static let buttonCornerRadius: CGFloat = 22
        static let forwardButtonHeight: CGFloat = 44
        static let segmentedControlHeight: CGFloat = 34
        static let loginSegmentIndex = 0
        static let registrationSegmentIndex = 1
        static let enabledAlpha: CGFloat = 1
        static let disabledAlpha: CGFloat = 0.55
    }
}
