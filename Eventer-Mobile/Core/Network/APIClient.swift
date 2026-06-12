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
    
    private init() {}
    
    func request<T: Decodable>(endpoint: String, method: String, body: Data? = nil, token: String? = nil) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        print("🚀 [NETWORK OUT] \(method) \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 [NETWORK IN] \(url.path)\nResponse: \(jsonString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401, 403:
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
}
