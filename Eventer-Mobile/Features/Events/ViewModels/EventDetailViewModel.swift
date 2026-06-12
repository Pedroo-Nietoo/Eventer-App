import Foundation
import Combine

@MainActor
class EventDetailViewModel: ObservableObject {
    @Published var ticketTypes: [TicketType] = []
    @Published var isLoadingTickets = false
    @Published var errorMessage: String? = nil
    
    private let repository: EventRepositoryProtocol
    
    init(repository: EventRepositoryProtocol = EventRepository()) {
        self.repository = repository
    }
    
    func loadTickets(for eventId: String, token: String) async {
        isLoadingTickets = true
        errorMessage = nil
        
        do {
            self.ticketTypes = try await repository.fetchTicketTypes(eventId: eventId, token: token)
        } catch {
            self.errorMessage = "Não foi possível carregar os ingressos."
            self.ticketTypes = []
        }
        
        isLoadingTickets = false
    }
}
