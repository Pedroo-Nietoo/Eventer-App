import Foundation
import Combine

@MainActor
class EventDetailViewModel: ObservableObject {
    @Published var ticketTypes: [TicketType] = []
    @Published var isLoadingTickets = false
    @Published var errorMessage: String? = nil
    
    @Published var selectedTicket: TicketType? = nil
    
    private let repository: EventRepositoryProtocol
    
    init(repository: EventRepositoryProtocol = EventRepository()) {
        self.repository = repository
    }
    
    func loadTickets(for eventId: String) async {
        isLoadingTickets = true
        errorMessage = nil
        
        do {
            self.ticketTypes = try await repository.fetchTicketTypes(eventId: eventId)
        } catch {
            self.errorMessage = "Não foi possível carregar os ingressos."
            self.ticketTypes = []
        }
        
        isLoadingTickets = false
    }
    
    func selectTicket(_ ticket: TicketType) {
        if selectedTicket?.id == ticket.id {
            selectedTicket = nil
        } else {
            selectedTicket = ticket
        }
    }
}
