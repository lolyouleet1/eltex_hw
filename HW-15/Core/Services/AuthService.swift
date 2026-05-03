import Foundation

protocol AuthServiceProtocol: AnyObject {
    var isAutoLoginEnabled: Bool { get set }
    var canAutoLogin: Bool { get }
    
    func register(login: String, password: String)
    func login(login: String, password: String) -> Bool
    func logout()
}

final class AuthService: AuthServiceProtocol {
    // MARK: - Dependencies
    private let storage: UserDefaults
    
    // MARK: - Lifecycle
    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }
    
    // MARK: - Public Methods
    var isAutoLoginEnabled: Bool {
        get {
            storage.bool(forKey: Constants.autoLoginKey)
        }
        set {
            storage.set(newValue, forKey: Constants.autoLoginKey)
        }
    }
    
    var canAutoLogin: Bool {
        isAutoLoginEnabled && isUserAuthorized && hasSavedCredentials
    }
    
    func register(login: String, password: String) {
        storage.set(login, forKey: Constants.loginKey)
        storage.set(password, forKey: Constants.passwordKey)
        setUserAuthorized(true)
    }
    
    func login(login: String, password: String) -> Bool {
        guard login == savedLogin,
              password == savedPassword else {
            return false
        }
        
        setUserAuthorized(true)
        return true
    }
    
    func logout() {
        setUserAuthorized(false)
    }
}

// MARK: - Private Methods
private extension AuthService {
    var savedLogin: String? {
        storage.string(forKey: Constants.loginKey)
    }
    
    var savedPassword: String? {
        storage.string(forKey: Constants.passwordKey)
    }
    
    var isUserAuthorized: Bool {
        storage.bool(forKey: Constants.userAuthorizedKey)
    }
    
    var hasSavedCredentials: Bool {
        savedLogin?.isEmpty == false && savedPassword?.isEmpty == false
    }
    
    func setUserAuthorized(_ isAuthorized: Bool) {
        storage.set(isAuthorized, forKey: Constants.userAuthorizedKey)
    }
}

// MARK: - Constants
private extension AuthService {
    enum Constants {
        static let loginKey = "auth.login"
        static let passwordKey = "auth.password"
        static let autoLoginKey = "auth.autoLogin"
        static let userAuthorizedKey = "auth.userAuthorized"
    }
}
