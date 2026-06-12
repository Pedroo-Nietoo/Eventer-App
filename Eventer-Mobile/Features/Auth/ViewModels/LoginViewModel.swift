import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var rememberMe = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }
    
    func login(sessionManager: AppSessionManager) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dto = LoginDto(email: email, password: password)
            let response = try await repository.login(dto: dto)
            sessionManager.saveSession(token: response.access_token, email: email)
        } catch {
            errorMessage = "Erro ao conectar: Verifique suas credenciais."
        }
        isLoading = false
    }
}
