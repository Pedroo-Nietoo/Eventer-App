import Foundation
import Combine

@MainActor
class TicketListViewModel: ObservableObject {
    @Published var tickets: [TicketResponseDto] = []
    @Published var isLoading: Bool = false

    private var currentPage = 1
    private var totalPages = 1
    private let repository: TicketRepositoryProtocol

    init(repository: TicketRepositoryProtocol = TicketRepository()) {
        self.repository = repository
    }

    var canLoadMore: Bool { currentPage < totalPages }

    func refreshTickets() async {
        currentPage = 1
        isLoading = true

        do {
            let response = try await repository.fetchMyTickets(page: currentPage, limit: 20)
            self.tickets = response.data
            self.totalPages = response.meta.totalPages
        } catch {
            print("Erro ao carregar ingressos: \(error)")
        }

        isLoading = false
    }

    func loadMore() async {
        guard canLoadMore, !isLoading else { return }
        currentPage += 1

        do {
            let response = try await repository.fetchMyTickets(page: currentPage, limit: 20)
            self.tickets.append(contentsOf: response.data)
            self.totalPages = response.meta.totalPages
        } catch {
            print("Erro na paginação de ingressos: \(error)")
        }
    }
}
