import Foundation

final class SettingsViewModel {
    // MARK: - Models
    struct ViewState {
        let isAutoLoginEnabled: Bool
    }
    
    // MARK: - Dependencies
    private let authService: AuthServiceProtocol
    
    // MARK: - State
    private(set) var viewState: ViewState
    var onStateChange: ((ViewState) -> Void)?
    
    // MARK: - Lifecycle
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        self.viewState = ViewState(
            isAutoLoginEnabled: authService.isAutoLoginEnabled
        )
    }
    
    // MARK: - Public Methods
    func handleAutoLoginChange(isOn: Bool) {
        authService.isAutoLoginEnabled = isOn
        publishState()
    }
    
    func handleLogout() {
        authService.logout()
    }
}

// MARK: - Private Methods
private extension SettingsViewModel {
    func publishState() {
        rebuildState()
        onStateChange?(viewState)
    }
    
    func rebuildState() {
        viewState = ViewState(
            isAutoLoginEnabled: authService.isAutoLoginEnabled
        )
    }
}
