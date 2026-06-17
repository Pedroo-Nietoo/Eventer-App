import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var enableBiometrics = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: AuthRepositoryProtocol
    private let biometricManager = BiometricManager()
    
    init(repository: AuthRepositoryProtocol = AuthRepository()) {
        self.repository = repository
        
        if let savedEmail = KeychainManager.shared.read(key: .userEmail) {
            self.email = savedEmail
        }
        
        if KeychainManager.shared.read(key: .biometricsEnabled) == "true" {
            self.enableBiometrics = true
        }
    }
    
    func login(sessionManager: AppSessionManager) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let dto = LoginDto(email: email, password: password)
            let response = try await repository.login(dto: dto)
            
            if enableBiometrics {
                KeychainManager.shared.save(key: .biometricsEnabled, value: "true")
                KeychainManager.shared.save(key: .userPassword, value: password)
            } else {
                KeychainManager.shared.delete(key: .biometricsEnabled)
                KeychainManager.shared.delete(key: .userPassword)
            }
            
            sessionManager.saveSession(accessToken: response.access_token, refreshToken: response.refresh_token, email: email)
        } catch {
            errorMessage = "Erro ao conectar: Verifique suas credenciais."
        }
        isLoading = false
    }
    
    func attemptBiometricLogin(sessionManager: AppSessionManager) {
        guard enableBiometrics,
              let savedEmail = KeychainManager.shared.read(key: .userEmail),
              let savedPassword = KeychainManager.shared.read(key: .userPassword) else {
            return
        }
        
        biometricManager.authenticate(reason: "Acesse sua conta do Eventer rapidamente") { [weak self] success in
            guard let self = self else { return }
            if success {
                self.email = savedEmail
                self.password = savedPassword
                Task {
                    await self.login(sessionManager: sessionManager)
                }
            }
        }
    }
}
