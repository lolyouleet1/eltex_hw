import Foundation

final class CompactCurrenciesViewModel {
    struct ViewState {
        let items: [CurrencyItemViewModel]
        let activeFilter: CompactFilterType
        let isFavoriteFilterHidden: Bool
    }
    
    enum CurrencySource {
        case repository
        case apiOnly([Currency])
    }
    
    // MARK: - Dependencies
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyFilterService: CurrencyFilterService
    private let currencySelectionService: CurrencySelectionService
    private let currencySource: CurrencySource
    
    // MARK: - Properties
    let selectionSide: SelectedSide
    
    // MARK: - State
    private var activeFilter: CompactFilterType
    private(set) var viewState: ViewState
    
    // MARK: - Lifecycle
    init(
        selectionSide: SelectedSide,
        currencyRepository: CurrencyRepositoryProtocol,
        currencyFilterService: CurrencyFilterService,
        currencySelectionService: CurrencySelectionService,
        currencySource: CurrencySource = .repository,
        activeFilter: CompactFilterType = .favorite
    ) {
        self.selectionSide = selectionSide
        self.currencyRepository = currencyRepository
        self.currencyFilterService = currencyFilterService
        self.currencySelectionService = currencySelectionService
        self.currencySource = currencySource
        self.activeFilter = activeFilter
        self.viewState = ViewState(
            items: [],
            activeFilter: activeFilter,
            isFavoriteFilterHidden: false
        )
        
        rebuildState()
    }
    
    // MARK: - Public Methods
    func handleFilterSelection(_ filter: CompactFilterType) {
        activeFilter = filter
        rebuildState()
    }
    
    func handleFavoriteToggle(at index: Int) {
        guard case .repository = currencySource else { return }
        guard viewState.items.indices.contains(index) else { return }
        
        let currencyID = viewState.items[index].id
        currencyRepository.toggleFavorite(currencyID: currencyID)
        rebuildState()
    }
    
    func handleCurrencySelection(at index: Int) -> Currency? {
        guard viewState.items.indices.contains(index) else { return nil }
        
        let currencyID = viewState.items[index].id
        
        guard currencySelectionService.select(currencyID: currencyID, for: selectionSide),
              let currency = availableCurrencies.first(where: { $0.id == currencyID }) else {
            return nil
        }
        
        rebuildState()
        
        return currency
    }
}

// MARK: - Private Methods
private extension CompactCurrenciesViewModel {
    func rebuildState() {
        let currencies = currencyFilterService.makeCurrencies(
            from: availableCurrencies,
            compactFilter: activeFilter
        )
        
        viewState = ViewState(
            items: makeItems(from: currencies),
            activeFilter: activeFilter,
            isFavoriteFilterHidden: isFavoriteFilterHidden
        )
    }
    
    var availableCurrencies: [Currency] {
        switch currencySource {
        case .repository:
            return currencyRepository.getCurrencies()
        case .apiOnly(let currencies):
            return currencies
        }
    }
    
    var isFavoriteFilterHidden: Bool {
        switch currencySource {
        case .repository:
            return false
        case .apiOnly:
            return true
        }
    }
    
    func makeItems(from currencies: [Currency]) -> [CurrencyItemViewModel] {
        currencies.map {
            CurrencyItemViewModel(
                id: $0.id,
                title: $0.code,
                isFavorite: $0.isFavorite,
                selectionState: currencySelectionService.selectionState(for: $0.id)
            )
        }
    }
}
