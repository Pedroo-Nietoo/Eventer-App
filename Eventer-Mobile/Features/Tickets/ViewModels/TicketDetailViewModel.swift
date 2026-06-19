import Foundation
import Combine

@MainActor
class TicketDetailViewModel: ObservableObject {
    @Published var ticket: TicketResponseDto
    @Published var isRefreshing: Bool = false

    private let repository: TicketRepositoryProtocol

    init(initialTicket: TicketResponseDto, repository: TicketRepositoryProtocol = TicketRepository()) {
        self.ticket = initialTicket
        self.repository = repository
    }

    var isQRUnlocked: Bool {
        guard let startDateString = ticket.eventStartDate else {
            return true
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let eventDate = formatter.date(from: startDateString) ?? ISO8601DateFormatter().date(from: startDateString) else {
            return true
        }

        let timeDifference = eventDate.timeIntervalSince(Date())
        return timeDifference <= (12 * 3600)
    }

    func refreshTicket() async {
        isRefreshing = true
        do {
            self.ticket = try await repository.fetchTicketDetails(ticketId: ticket.id)
        } catch {
            print("Erro ao atualizar detalhes do ingresso: \(error)")
        }
        isRefreshing = false
    }
}
