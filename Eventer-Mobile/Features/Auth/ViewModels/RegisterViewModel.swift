import Foundation
import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegisteredSuccessfully = false
    
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
    }
    
    func register() async {
        guard !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Preencha todos os campos obrigatórios."
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "A senha deve ter no mínimo 6 caracteres."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "As senhas não coincidem."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let dto = CreateUserDto(username: username, email: email, password: password, profilePicture: nil)
        
        do {
            _ = try await repository.register(dto: dto)
            self.isRegisteredSuccessfully = true
        } catch let error as APIError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = "Ocorreu um erro inesperado."
        }
        
        isLoading = false
    }
}
