import SwiftUI

struct RootView: View {
    @EnvironmentObject var sessionManager: AppSessionManager
    
    var body: some View {
        Group {
            if sessionManager.isAuthenticated {
                MainTabView()
                    .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: sessionManager.isAuthenticated)
    }
}
