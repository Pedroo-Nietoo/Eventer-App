import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(statusCode: Int)
    case unauthorized
    case conflict
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "A URL da requisição é inválida."
        case .noData: return "O servidor não retornou dados."
        case .decodingError(let err): return "Erro ao processar dados do servidor: \(err.localizedDescription)"
        case .serverError(let code): return "Erro no servidor (Status \(code))."
        case .unauthorized: return "E-mail, senha incorretos ou token expirado."
        case .conflict: return "Dados já existentes (ex: e-mail já em uso)."
        case .unknown(let err): return "Erro desconhecido: \(err.localizedDescription)"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://eventer-api-dev.onrender.com"
    
    static let sessionExpiredNotification = Notification.Name("SessionExpiredNotification")
    
    private init() {}
    
    func request<T: Decodable>(endpoint: String, method: String, body: Data? = nil, isRetry: Bool = false) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = KeychainManager.shared.read(key: .accessToken) {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        print("🚀 [NETWORK OUT] \(method) \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 [NETWORK IN] \(url.path)\nResponse: \(jsonString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            
            if httpResponse.statusCode == 401 {
                if !isRetry {
                    print("⚠️ [NETWORK] Access Token expirado. Tentando obter Refresh Token...")
                    return try await handleRefreshToken(endpoint: endpoint, method: method, originalBody: body)
                } else {
                    print("❌ [NETWORK] Erro 401 persistente após tentativa de Refresh.")
                    NotificationCenter.default.post(name: APIClient.sessionExpiredNotification, object: nil)
                    throw APIError.unauthorized
                }
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 403:
                throw APIError.unauthorized
            case 409:
                throw APIError.conflict
            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(T.self, from: data)
        } catch let apiError as APIError {
            print("❌ [NETWORK ERROR] \(apiError.localizedDescription)")
            throw apiError
        } catch {
            print("❌ [DECODE/UNKNOWN ERROR] \(error)")
            throw APIError.unknown(error)
        }
    }
    
    private func handleRefreshToken<T: Decodable>(endpoint: String, method: String, originalBody: Data?) async throws -> T {
        guard let refreshToken = KeychainManager.shared.read(key: .refreshToken) else {
            print("❌ [REFRESH] Nenhum Refresh Token localizado no Keychain.")
            NotificationCenter.default.post(name: APIClient.sessionExpiredNotification, object: nil)
            throw APIError.unauthorized
        }
        
        guard let url = URL(string: baseURL + "/auth/refresh") else {
            throw APIError.invalidURL
        }
        
        let refreshDto = RefreshRequestDto(refresh_token: refreshToken)
        
        var refreshRequest = URLRequest(url: url)
        refreshRequest.httpMethod = "POST"
        refreshRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        refreshRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        refreshRequest.httpBody = try? JSONEncoder().encode(refreshDto)
        
        print("🔄 [REFRESH OUT] POST \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: refreshRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("❌ [REFRESH] Falha ao renovar token no backend. Sessão completamente expirada.")
                NotificationCenter.default.post(name: APIClient.sessionExpiredNotification, object: nil)
                throw APIError.unauthorized
            }
            
            let refreshResponse = try JSONDecoder().decode(RefreshResponseDto.self, from: data)
            KeychainManager.shared.save(key: .accessToken, value: refreshResponse.access_token)
            KeychainManager.shared.save(key: .refreshToken, value: refreshResponse.refresh_token)
            print("✅ [REFRESH] Novo Access Token gerado com sucesso!")
            
            return try await self.request(endpoint: endpoint, method: method, body: originalBody, isRetry: true)
        } catch {
            NotificationCenter.default.post(name: APIClient.sessionExpiredNotification, object: nil)
            throw APIError.unauthorized
        }
    }
}
