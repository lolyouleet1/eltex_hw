import Combine
import Foundation

final class AuthViewModel {
    // MARK: - Models
    struct ViewState {
        let mode: AuthMode
        let isForwardButtonEnabled: Bool
    }
    
    enum AuthMode {
        case login
        case registration
    }
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    private let logger: AppLoggerProtocol
    
    // MARK: - State
    @Published private var loginText = Constants.emptyText
    @Published private var passwordText = Constants.emptyText
    @Published private var mode: AuthMode = .login
    
    @Published private(set) var viewState: ViewState
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    init(authService: AuthServiceProtocol, logger: AppLoggerProtocol = AppLogger.authorization) {
        self.authService = authService
        self.logger = logger
        self.viewState = Self.makeViewState(
            loginText: Constants.emptyText,
            passwordText: Constants.emptyText,
            mode: .login
        )
        
        bindState()
    }
    
    // MARK: - Public Methods
    var viewStatePublisher: AnyPublisher<ViewState, Never> {
        $viewState.eraseToAnyPublisher()
    }
    
    func handleLoginChange(_ login: String?) {
        loginText = makePreparedText(from: login)
    }
    
    func handlePasswordChange(_ password: String?) {
        passwordText = makePreparedText(from: password)
    }
    
    func handleModeSelection(_ mode: AuthMode) {
        self.mode = mode
        logger.info(
            Constants.modeChangedMessage,
            metadata: [
                AppLogMetadataKey.mode: mode.logDescription
            ]
        )
    }
    
    func handleForwardButtonTapped() -> Bool {
        guard viewState.isForwardButtonEnabled else {
            logger.warning(
                Constants.authorizationRejectedMessage,
                metadata: [
                    AppLogMetadataKey.reason: Constants.invalidInputReason
                ]
            )
            return false
        }
        
        logger.info(
            Constants.authorizationStartedMessage,
            metadata: [
                AppLogMetadataKey.mode: mode.logDescription
            ]
        )
        
        switch mode {
        case .login:
            let isCompleted = authService.login(login: loginText, password: passwordText)
            
            if isCompleted {
                logger.info(
                    Constants.authorizationCompletedMessage,
                    metadata: [
                        AppLogMetadataKey.mode: mode.logDescription
                    ]
                )
            } else {
                logger.warning(
                    Constants.authorizationRejectedMessage,
                    metadata: [
                        AppLogMetadataKey.mode: mode.logDescription,
                        AppLogMetadataKey.reason: Constants.invalidCredentialsReason
                    ]
                )
            }
            
            return isCompleted
        case .registration:
            authService.register(login: loginText, password: passwordText)
            logger.info(
                Constants.authorizationCompletedMessage,
                metadata: [
                    AppLogMetadataKey.mode: mode.logDescription
                ]
            )
            return true
        }
    }
}

// MARK: - Private Methods
private extension AuthViewModel {
    func bindState() {
        Publishers.CombineLatest3($loginText, $passwordText, $mode)
            .map { loginText, passwordText, mode in
                Self.makeViewState(
                    loginText: loginText,
                    passwordText: passwordText,
                    mode: mode
                )
            }
            .sink { [weak self] viewState in
                self?.viewState = viewState
            }
            .store(in: &cancellables)
    }
    
    func makePreparedText(from text: String?) -> String {
        text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Constants.emptyText
    }
    
    static func makeViewState(loginText: String, passwordText: String, mode: AuthMode) -> ViewState {
        ViewState(
            mode: mode,
            isForwardButtonEnabled: isInputValid(
                loginText: loginText,
                passwordText: passwordText
            )
        )
    }
    
    static func isInputValid(loginText: String, passwordText: String) -> Bool {
        loginText.count >= Constants.minimumLoginLength
        && passwordText.count >= Constants.minimumPasswordLength
    }
}

// MARK: - Constants
private extension AuthViewModel {
    enum Constants {
        static let emptyText = ""
        static let minimumLoginLength = 1
        static let minimumPasswordLength = 1
        static let modeChangedMessage = "The authorization mode was changed."
        static let authorizationStartedMessage = "Authorization processing was started."
        static let authorizationCompletedMessage = "Authorization processing was completed successfully."
        static let authorizationRejectedMessage = "Authorization processing was rejected."
        static let invalidInputReason = "invalidInput"
        static let invalidCredentialsReason = "invalidCredentials"
    }
}

// MARK: - AuthViewModel.AuthMode
private extension AuthViewModel.AuthMode {
    var logDescription: String {
        switch self {
        case .login:
            return Constants.loginModeText
        case .registration:
            return Constants.registrationModeText
        }
    }
    
    enum Constants {
        static let loginModeText = "login"
        static let registrationModeText = "registration"
    }
}
