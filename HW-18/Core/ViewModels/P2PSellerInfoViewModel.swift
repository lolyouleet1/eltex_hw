import Foundation

final class P2PSellerInfoViewModel {
    // MARK: - Models
    struct ViewState {
        let sellerNameText: String
        let verificationText: String
        let descriptionText: String
        let ratingText: String
        let completedTradesText: String
        let responseTimeText: String
        let paymentMethodsText: String
        let rateText: String
        let reserveText: String
    }
    
    // MARK: - Dependencies
    private let offer: P2POffer
    
    // MARK: - State
    private(set) var viewState: ViewState
    
    // MARK: - Lifecycle
    init(offer: P2POffer) {
        self.offer = offer
        self.viewState = ViewState(
            sellerNameText: Constants.emptyText,
            verificationText: Constants.emptyText,
            descriptionText: Constants.emptyText,
            ratingText: Constants.emptyText,
            completedTradesText: Constants.emptyText,
            responseTimeText: Constants.emptyText,
            paymentMethodsText: Constants.emptyText,
            rateText: Constants.emptyText,
            reserveText: Constants.emptyText
        )
        
        rebuildState()
    }
}

// MARK: - Private Methods
private extension P2PSellerInfoViewModel {
    func rebuildState() {
        viewState = ViewState(
            sellerNameText: offer.sellerName,
            verificationText: makeVerificationText(),
            descriptionText: makeDescriptionText(),
            ratingText: makeRatingText(),
            completedTradesText: makeCompletedTradesText(),
            responseTimeText: makeResponseTimeText(),
            paymentMethodsText: makePaymentMethodsText(),
            rateText: makeRateText(),
            reserveText: makeReserveText()
        )
    }
    
    func makeVerificationText() -> String {
        if sellerScore.isMultiple(of: Constants.verificationDivider) {
            return Constants.verifiedStatusText
        }
        
        return Constants.trustedStatusText
    }
    
    func makeDescriptionText() -> String {
        "\(offer.sellerName)\(Constants.descriptionSuffix)"
    }
    
    func makeRatingText() -> String {
        let rating = Constants.minRating + Float(sellerScore % Constants.ratingSteps) / Constants.ratingDivider
        let ratingText = String(format: Constants.ratingFormat, rating)
        
        return "\(Constants.ratingTitle)\(ratingText)"
    }
    
    func makeCompletedTradesText() -> String {
        let completedTrades = Constants.minCompletedTrades + sellerScore % Constants.completedTradesRange
        
        return "\(Constants.completedTradesTitle)\(completedTrades)"
    }
    
    func makeResponseTimeText() -> String {
        let responseTime = Constants.minResponseMinutes + sellerScore % Constants.responseMinutesRange
        
        return "\(Constants.responseTimeTitle)\(responseTime)\(Constants.minutesSuffix)"
    }
    
    func makePaymentMethodsText() -> String {
        let paymentMethodsIndex = sellerScore % Constants.paymentMethodGroups.count
        
        return "\(Constants.paymentMethodsTitle)\(Constants.paymentMethodGroups[paymentMethodsIndex])"
    }
    
    func makeRateText() -> String {
        let rateText = AppConfiguration.PriceFormatting.string(from: offer.rate)
        
        return "\(Constants.rateTitle)\(rateText)\(Constants.textSeparator)\(offer.receiveCurrencyCode)"
    }
    
    func makeReserveText() -> String {
        let reserveText = AppConfiguration.PriceFormatting.string(from: offer.reserve)
        
        return "\(Constants.reserveTitle)\(reserveText)\(Constants.textSeparator)\(offer.receiveCurrencyCode)"
    }
    
    var sellerScore: Int {
        offer.sellerName.unicodeScalars.reduce(Constants.initialScore) {
            $0 + Int($1.value)
        }
    }
}

// MARK: - Constants
private extension P2PSellerInfoViewModel {
    enum Constants {
        static let emptyText = ""
        static let verifiedStatusText = "Verified seller"
        static let trustedStatusText = "Trusted seller"
        static let descriptionSuffix = " keeps a stable reserve and usually works with small and medium exchange orders."
        static let ratingTitle = "Rating: "
        static let completedTradesTitle = "Completed trades: "
        static let responseTimeTitle = "Average response: "
        static let minutesSuffix = " min"
        static let paymentMethodsTitle = "Payment methods: "
        static let rateTitle = "Current rate: "
        static let reserveTitle = "Available reserve: "
        static let ratingFormat = "%.1f/5"
        static let textSeparator = " "
        static let paymentMethodGroups = [
            "Bank card, fast transfer",
            "Bank card, cash desk",
            "Fast transfer, crypto wallet",
            "Bank card, SBP"
        ]
        static let initialScore = 0
        static let verificationDivider = 2
        static let minRating: Float = 4.4
        static let ratingSteps = 6
        static let ratingDivider: Float = 10
        static let minCompletedTrades = 120
        static let completedTradesRange = 880
        static let minResponseMinutes = 2
        static let responseMinutesRange = 14
    }
}
