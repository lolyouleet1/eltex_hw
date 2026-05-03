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
    private var loginText = Constants.emptyText
    private var passwordText = Constants.emptyText
    private var mode: AuthMode = .login
    
    private(set) var viewState: ViewState
    var onStateChange: ((ViewState) -> Void)?
    
    // MARK: - Lifecycle
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        self.viewState = ViewState(
            mode: mode,
            isForwardButtonEnabled: false
        )
        
        rebuildState()
    }
    
    // MARK: - Public Methods
    func handleLoginChange(_ login: String?) {
        loginText = makePreparedText(from: login)
        publishState()
    }
    
    func handlePasswordChange(_ password: String?) {
        passwordText = makePreparedText(from: password)
        publishState()
    }
    
    func handleModeSelection(_ mode: AuthMode) {
        self.mode = mode
        publishState()
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
    var isInputValid: Bool {
        loginText.count >= Constants.minimumLoginLength
        && passwordText.count >= Constants.minimumPasswordLength
    }
    
    func publishState() {
        rebuildState()
        onStateChange?(viewState)
    }
    
    func rebuildState() {
        viewState = ViewState(
            mode: mode,
            isForwardButtonEnabled: isInputValid
        )
    }
    
    func makePreparedText(from text: String?) -> String {
        text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? Constants.emptyText
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
