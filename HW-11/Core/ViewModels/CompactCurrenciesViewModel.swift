import Foundation

final class CompactCurrenciesViewModel {
    struct ViewState {
        let items: [CurrencyItemViewModel]
        let activeFilter: CompactFilterType
    }
    
    // MARK: - Dependencies
    private let currencyRepository: CurrencyRepositoryProtocol
    private let currencyFilterService: CurrencyFilterService
    private let currencySelectionService: CurrencySelectionService
    
    // MARK: - Properties
    let selectionSide: SelectedSide
    
    // MARK: - State
    private var activeFilter: CompactFilterType = .favorite
    private(set) var viewState: ViewState
    
    // MARK: - Lifecycle
    init(selectionSide: SelectedSide, currencyRepository: CurrencyRepositoryProtocol, currencyFilterService: CurrencyFilterService, currencySelectionService: CurrencySelectionService) {
        self.selectionSide = selectionSide
        self.currencyRepository = currencyRepository
        self.currencyFilterService = currencyFilterService
        self.currencySelectionService = currencySelectionService
        self.viewState = ViewState(items: [], activeFilter: .favorite)
        
        rebuildState()
    }
    
    // MARK: - Public Methods
    func handleFilterSelection(_ filter: CompactFilterType) {
        activeFilter = filter
        rebuildState()
    }
    
    func handleFavoriteToggle(at index: Int) {
        guard viewState.items.indices.contains(index) else { return }
        
        let currencyID = viewState.items[index].id
        currencyRepository.toggleFavorite(currencyID: currencyID)
        rebuildState()
    }
    
    func handleCurrencySelection(at index: Int) -> Currency? {
        guard viewState.items.indices.contains(index) else { return nil }
        
        let currencyID = viewState.items[index].id
        
        guard currencySelectionService.select(currencyID: currencyID, for: selectionSide),
              let currency = currencyRepository.getCurrency(id: currencyID) else {
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
            from: currencyRepository.getCurrencies(),
            compactFilter: activeFilter
        )
        
        viewState = ViewState(
            items: makeItems(from: currencies),
            activeFilter: activeFilter
        )
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
