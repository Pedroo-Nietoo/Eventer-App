import SwiftUI

struct LoginActionsView: View {
    @ObservedObject var viewModel: LoginViewModel
    var sessionManager: AppSessionManager
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task { await viewModel.login(sessionManager: sessionManager) }
            }) {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Entrar")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)
            
            NavigationLink("Ainda não tem conta? Cadastre-se", destination: RegisterView())
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
                .padding(.top, 16)
        }
    }
}
