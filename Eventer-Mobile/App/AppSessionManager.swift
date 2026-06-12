import Foundation
import CoreData
import Combine

@MainActor
class AppSessionManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserEmail: String?
    @Published var token: String?
    
    private let context = CoreDataManager.shared.viewContext
    
    init() {
        checkExistingSession()
    }
    
    func checkExistingSession() {
        let request = NSFetchRequest<UserSessionEntity>(entityName: "UserSessionEntity")
        do {
            let sessions = try context.fetch(request)
            if let activeSession = sessions.first {
                self.currentUserEmail = activeSession.email
                self.token = activeSession.token
                self.isAuthenticated = true
            }
        } catch {
            print("Erro ao carregar sessão.")
        }
    }
    
    func saveSession(token: String, email: String) {
        clearSessions()
        
        let newSession = UserSessionEntity(context: context)
        newSession.token = token
        newSession.email = email
        
        CoreDataManager.shared.saveContext()
        
        self.currentUserEmail = email
        self.token = token
        self.isAuthenticated = true
    }
    
    func logout() {
        clearSessions()
        self.isAuthenticated = false
        self.currentUserEmail = nil
        self.token = nil
    }
    
    private func clearSessions() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserSessionEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        _ = try? context.execute(deleteRequest)
        CoreDataManager.shared.saveContext()
    }
}
