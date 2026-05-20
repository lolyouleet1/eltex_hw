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
    
    // MARK: - State
    @Published private var loginText = Constants.emptyText
    @Published private var passwordText = Constants.emptyText
    @Published private var mode: AuthMode = .login
    
    @Published private(set) var viewState: ViewState
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Lifecycle
    init(authService: AuthServiceProtocol) {
        self.authService = authService
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
    }
    
    func handleForwardButtonTapped() -> Bool {
        guard viewState.isForwardButtonEnabled else { return false }
        
        switch mode {
        case .login:
            return authService.login(login: loginText, password: passwordText)
        case .registration:
            authService.register(login: loginText, password: passwordText)
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
    }
}
