import SwiftUI

@main
struct Eventer_MobileApp: App {
    @StateObject private var sessionManager = AppSessionManager()
    
    let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
                .environment(\.managedObjectContext, coreDataManager.viewContext)
        }
    }
}
