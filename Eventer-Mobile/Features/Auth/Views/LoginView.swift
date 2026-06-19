import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var sessionManager: AppSessionManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                LoginHeaderView()
                    .padding(.bottom, 16)
                
                LoginFormView(viewModel: viewModel)
                
                LoginActionsView(viewModel: viewModel, sessionManager: sessionManager)
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
            .onAppear {
                if viewModel.enableBiometrics && !viewModel.email.isEmpty {
                    viewModel.attemptBiometricLogin(sessionManager: sessionManager)
                }
            }
        }
    }
}
