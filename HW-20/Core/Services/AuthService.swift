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
    private let logger: AppLoggerProtocol
    
    // MARK: - Lifecycle
    init(storage: UserDefaults = .standard, logger: AppLoggerProtocol = AppLogger.authorization) {
        self.storage = storage
        self.logger = logger
    }
    
    // MARK: - Public Methods
    var isAutoLoginEnabled: Bool {
        get {
            storage.bool(forKey: Constants.autoLoginKey)
        }
        set {
            storage.set(newValue, forKey: Constants.autoLoginKey)
            logger.info(
                Constants.autoLoginStateChangedMessage,
                metadata: [
                    AppLogMetadataKey.status: String(newValue)
                ]
            )
        }
    }
    
    var canAutoLogin: Bool {
        let canAutoLogin = isAutoLoginEnabled && isUserAuthorized && hasSavedCredentials
        
        if !canAutoLogin {
            logger.info(
                Constants.autoLoginRejectedMessage,
                metadata: [
                    AppLogMetadataKey.reason: makeAutoLoginRejectionReason()
                ]
            )
        }
        
        return canAutoLogin
    }
    
    func register(login: String, password: String) {
        logger.info(Constants.registrationStartedMessage)
        storage.set(login, forKey: Constants.loginKey)
        storage.set(password, forKey: Constants.passwordKey)
        setUserAuthorized(true)
        logger.info(Constants.registrationCompletedMessage)
    }
    
    func login(login: String, password: String) -> Bool {
        logger.info(Constants.loginStartedMessage)
        
        guard login == savedLogin,
              password == savedPassword else {
            logger.warning(
                Constants.loginRejectedMessage,
                metadata: [
                    AppLogMetadataKey.reason: Constants.invalidCredentialsReason
                ]
            )
            return false
        }
        
        setUserAuthorized(true)
        logger.info(Constants.loginCompletedMessage)
        return true
    }
    
    func logout() {
        setUserAuthorized(false)
        logger.info(Constants.logoutCompletedMessage)
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
    
    func makeAutoLoginRejectionReason() -> String {
        guard isAutoLoginEnabled else { return Constants.autoLoginDisabledReason }
        guard isUserAuthorized else { return Constants.userIsNotAuthorizedReason }
        guard hasSavedCredentials else { return Constants.missingCredentialsReason }
        
        return Constants.unknownReason
    }
}

// MARK: - Constants
private extension AuthService {
    enum Constants {
        static let loginKey = "auth.login"
        static let passwordKey = "auth.password"
        static let autoLoginKey = "auth.autoLogin"
        static let userAuthorizedKey = "auth.userAuthorized"
        static let autoLoginStateChangedMessage = "The automatic login setting was changed."
        static let autoLoginRejectedMessage = "Automatic login was not permitted."
        static let registrationStartedMessage = "User registration was started."
        static let registrationCompletedMessage = "User registration was completed successfully."
        static let loginStartedMessage = "User login was started."
        static let loginCompletedMessage = "User login was completed successfully."
        static let loginRejectedMessage = "User login was rejected."
        static let logoutCompletedMessage = "User logout was completed."
        static let invalidCredentialsReason = "invalidCredentials"
        static let autoLoginDisabledReason = "autoLoginDisabled"
        static let userIsNotAuthorizedReason = "userIsNotAuthorized"
        static let missingCredentialsReason = "missingCredentials"
        static let unknownReason = "unknown"
    }
}
