import Foundation

protocol AuthRepositoryProtocol {
    func login(dto: LoginDto) async throws -> LoginResponseDto
    func register(dto: CreateUserDto) async throws -> UserResponseDto
}

class AuthRepository: AuthRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func login(dto: LoginDto) async throws -> LoginResponseDto {
        let data = try JSONEncoder().encode(dto)
        return try await apiClient.request(endpoint: "/auth/login", method: "POST", body: data)
    }
    
    func register(dto: CreateUserDto) async throws -> UserResponseDto {
        let data = try JSONEncoder().encode(dto)
        return try await apiClient.request(endpoint: "/users", method: "POST", body: data)
    }
}
