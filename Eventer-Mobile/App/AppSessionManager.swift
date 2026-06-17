import Foundation
import Combine

@MainActor
class AppSessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserEmail: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        checkExistingSession()
        setupNotificationListeners()
    }
    
    private func setupNotificationListeners() {
        NotificationCenter.default.publisher(for: APIClient.sessionExpiredNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.logout()
            }
            .store(in: &cancellables)
    }
    
    func checkExistingSession() {
        if KeychainManager.shared.read(key: .accessToken) != nil {
            self.currentUserEmail = KeychainManager.shared.read(key: .userEmail)
            self.isAuthenticated = true
        } else {
            self.isAuthenticated = false
        }
    }
    
    func saveSession(accessToken: String, refreshToken: String, email: String) {
        KeychainManager.shared.save(key: .accessToken, value: accessToken)
        KeychainManager.shared.save(key: .refreshToken, value: refreshToken)
        KeychainManager.shared.save(key: .userEmail, value: email)
        
        self.currentUserEmail = email
        self.isAuthenticated = true
    }
    
    func logout() {
        KeychainManager.shared.clearAllSessionData()
        self.isAuthenticated = false
        self.currentUserEmail = nil
    }
}
