import Foundation

protocol EventRepositoryProtocol {
    func fetchEvents(page: Int, limit: Int, token: String) async throws -> [Event]
    func fetchNearbyEvents(lat: Double, lng: Double, radius: Double, token: String) async throws -> [Event]
    func fetchTicketTypes(eventId: String, token: String) async throws -> [TicketType] // 🚨 NOVA ROTA
}
class EventRepository: EventRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchEvents(page: Int = 1, limit: Int = 20, token: String) async throws -> [Event] {
        struct PaginatedResponse: Decodable {
            let data: [Event]
        }
        
        let response: PaginatedResponse = try await apiClient.request(
            endpoint: "/events?page=\(page)&limit=\(limit)",
            method: "GET",
            token: token
        )
        return response.data
    }
    
    func fetchNearbyEvents(lat: Double, lng: Double, radius: Double, token: String) async throws -> [Event] {
        let usLocale = Locale(identifier: "en_US")
        let latStr = String(format: "%.6f", locale: usLocale, lat)
        let lngStr = String(format: "%.6f", locale: usLocale, lng)
        let radiusStr = String(Int(radius))
        
        let endpoint = "/events/nearby?lat=\(latStr)&lng=\(lngStr)&radius=\(radiusStr)"
        
        print("📍 [REQUEST NEARBY] Rota gerada: \(endpoint)")
        
        let response: [Event] = try await apiClient.request(
            endpoint: endpoint,
            method: "GET",
            token: token
        )
        return response
    }
    
    func fetchTicketTypes(eventId: String, token: String) async throws -> [TicketType] {
        let endpoint = "/ticket-types?eventId=\(eventId)"
        
        print("🎟️ [REQUEST TICKETS] Rota gerada: \(endpoint)")
        
        let response: [TicketType] = try await apiClient.request(
            endpoint: endpoint,
            method: "GET",
            token: token
        )
        return response
    }
}
