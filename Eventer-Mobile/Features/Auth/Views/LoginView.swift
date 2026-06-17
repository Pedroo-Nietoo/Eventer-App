import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var sessionManager: AppSessionManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 12) {
                    Image(systemName: "ticket.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 50)
                        .foregroundColor(.accentColor)
                    
                    Text("Acesse sua conta")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 16)
                
                VStack(spacing: 16) {
                    TextField("E-mail", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    SecureInputView(title: "Senha", text: $viewModel.password)
                }
                
                Toggle("Entrar com Biometria", isOn: $viewModel.enableBiometrics)
                    .padding(.vertical, 8)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                
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
