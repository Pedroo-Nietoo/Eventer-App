import SwiftUI

@main
struct Eventer_MobileApp: App {
    @StateObject private var sessionManager = AppSessionManager()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
        }
    }
}
