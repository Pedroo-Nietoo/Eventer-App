import Foundation

protocol UserRepositoryProtocol {
    func getMyProfile() async throws -> UserResponseDto
    func getPresignedUrl(dto: PresignedUrlRequestDto) async throws -> PresignedUrlResponseDto
    func uploadToS3(presignedUrl: String, fields: [String: String], fileData: Data, mimeType: String, fileName: String) async throws
    func updateProfile(userId: String, dto: UpdateProfileDto) async throws
}

class UserRepository: UserRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }
    
    func getMyProfile() async throws -> UserResponseDto {
        return try await apiClient.request(endpoint: "/users/me", method: "GET")
    }
    
    func getPresignedUrl(dto: PresignedUrlRequestDto) async throws -> PresignedUrlResponseDto {
        let body = try JSONEncoder().encode(dto)
        return try await apiClient.request(endpoint: "/uploads/presigned-url", method: "POST", body: body)
    }
    
    func updateProfile(userId: String, dto: UpdateProfileDto) async throws {
        let body = try JSONEncoder().encode(dto)
        let _: UserResponseDto? = try? await apiClient.request(endpoint: "/users/\(userId)", method: "PATCH", body: body)
    }
    
    func uploadToS3(presignedUrl: String, fields: [String: String], fileData: Data, mimeType: String, fileName: String) async throws {
        guard let url = URL(string: presignedUrl) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 500)
        }
    }
}
