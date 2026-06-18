import Foundation
import Combine

@MainActor
class OrderHistoryViewModel: ObservableObject {
    @Published var orders: [OrderResponseDto] = []
    @Published var isLoading: Bool = false
    @Published var isFetchingMore: Bool = false
    
    private var currentPage = 1
    private var totalPages = 1
    private let limit = 20
    private let repository: OrderRepositoryProtocol
    
    var canLoadMore: Bool {
        currentPage < totalPages
    }
    
    init(repository: OrderRepositoryProtocol = OrderRepository()) {
        self.repository = repository
    }
    
    func refreshOrders() async {
        currentPage = 1
        isLoading = true
        orders.removeAll()
        
        await fetch()
        isLoading = false
    }
    
    func loadMoreOrders() async {
        guard canLoadMore, !isFetchingMore, !isLoading else { return }
        
        isFetchingMore = true
        currentPage += 1
        
        await fetch()
        isFetchingMore = false
    }
    
    private func fetch() async {
        do {
            let response = try await repository.fetchMyOrders(page: currentPage, limit: limit)
            
            if currentPage == 1 {
                self.orders = response.data
            } else {
                self.orders.append(contentsOf: response.data)
            }
            
            self.totalPages = response.meta.totalPages
        } catch {
            print("Erro ao buscar histórico de pedidos: \(error.localizedDescription)")
        }
    }
}
