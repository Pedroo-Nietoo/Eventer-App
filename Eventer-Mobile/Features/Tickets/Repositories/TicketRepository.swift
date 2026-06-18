import Foundation

protocol TicketRepositoryProtocol {
    func fetchMyTickets(page: Int, limit: Int) async throws -> PaginatedResponse<TicketResponseDto>
    func fetchTicketDetails(ticketId: String) async throws -> TicketResponseDto
}
class TicketRepository: TicketRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchMyTickets(page: Int = 1, limit: Int = 20) async throws -> PaginatedResponse<TicketResponseDto> {
        let endpoint = "/tickets?page=\(page)&limit=\(limit)"
        return try await apiClient.request(endpoint: endpoint, method: "GET")
    }
    
    func fetchTicketDetails(ticketId: String) async throws -> TicketResponseDto {
        let endpoint = "/tickets/\(ticketId)"
        return try await apiClient.request(endpoint: endpoint, method: "GET")
    }
}
