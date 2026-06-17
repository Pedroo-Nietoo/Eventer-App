import Foundation

protocol EventRepositoryProtocol {
    func fetchEvents(page: Int, limit: Int, query: String?) async throws -> PaginatedResponse<Event>
    func fetchNearbyEvents(lat: Double, lng: Double, radius: Double) async throws -> [Event]
    func fetchTicketTypes(eventId: String) async throws -> [TicketType]
}

class EventRepository: EventRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func fetchEvents(page: Int = 1, limit: Int = 20, query: String? = nil) async throws -> PaginatedResponse<Event> {
        var endpoint = "/events?page=\(page)&limit=\(limit)"
        
        if let query = query, !query.isEmpty, let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            endpoint += "&q=\(encodedQuery)"
        }
        
        print("🔍 [REQUEST EVENTS] Rota gerada: \(endpoint)")
        
        return try await apiClient.request(
            endpoint: endpoint,
            method: "GET"
        )
    }
    
    func fetchNearbyEvents(lat: Double, lng: Double, radius: Double) async throws -> [Event] {
        let usLocale = Locale(identifier: "en_US")
        let latStr = String(format: "%.6f", locale: usLocale, lat)
        let lngStr = String(format: "%.6f", locale: usLocale, lng)
        let radiusStr = String(Int(radius))
        
        let endpoint = "/events/nearby?lat=\(latStr)&lng=\(lngStr)&radius=\(radiusStr)"
        
        print("📍 [REQUEST NEARBY] Rota gerada: \(endpoint)")
        
        let response: [Event] = try await apiClient.request(
            endpoint: endpoint,
            method: "GET"
        )
        return response
    }
    
    func fetchTicketTypes(eventId: String) async throws -> [TicketType] {
        let endpoint = "/ticket-types?eventId=\(eventId)"
        
        print("🎟️ [REQUEST TICKETS] Rota gerada: \(endpoint)")
        
        let response: PaginatedResponse<TicketType> = try await apiClient.request(
            endpoint: endpoint,
            method: "GET"
        )
        
        return response.data
    }
}
