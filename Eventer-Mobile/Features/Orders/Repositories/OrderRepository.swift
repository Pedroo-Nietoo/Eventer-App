import Foundation

protocol OrderRepositoryProtocol {
    func createOrder(dto: CreateOrderRequestDto) async throws -> CreateOrderResponseDto
    func fetchMyOrders(page: Int, limit: Int) async throws -> PaginatedResponse<OrderResponseDto>
}

class OrderRepository: OrderRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func createOrder(dto: CreateOrderRequestDto) async throws -> CreateOrderResponseDto {
        let body = try JSONEncoder().encode(dto)
        return try await apiClient.request(endpoint: "/orders", method: "POST", body: body)
    }
    
    func fetchMyOrders(page: Int = 1, limit: Int = 20) async throws -> PaginatedResponse<OrderResponseDto> {
        let endpoint = "/orders?page=\(page)&limit=\(limit)"
        return try await apiClient.request(endpoint: endpoint, method: "GET")
    }
}
