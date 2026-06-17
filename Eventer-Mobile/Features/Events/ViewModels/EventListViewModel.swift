import Foundation
import Combine

@MainActor
class EventListViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var isFetchingMore: Bool = false
    
    private var currentPage = 1
    private var totalPages = 1
    private let limit = 20
    
    private let repository: EventRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var canLoadMore: Bool {
        currentPage < totalPages
    }
    
    init(repository: EventRepositoryProtocol = EventRepository()) {
        self.repository = repository
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshEvents()
                }
            }
            .store(in: &cancellables)
    }
    
    func refreshEvents() async {
        currentPage = 1
        isLoading = true
        events.removeAll()
        
        await fetch()
        isLoading = false
    }
    
    func loadMoreEvents() async {
        guard canLoadMore, !isFetchingMore, !isLoading else { return }
        
        isFetchingMore = true
        currentPage += 1
        
        await fetch()
        isFetchingMore = false
    }
    
    private func fetch() async {
        do {
            let response = try await repository.fetchEvents(page: currentPage, limit: limit, query: searchText)
            
            if currentPage == 1 {
                self.events = response.data
            } else {
                self.events.append(contentsOf: response.data)
            }
            
            self.totalPages = response.meta.totalPages
        } catch {
            print("Erro ao buscar eventos na lista: \(error.localizedDescription)")
        }
    }
}
