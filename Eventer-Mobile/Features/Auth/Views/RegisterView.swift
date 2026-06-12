import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Criar Nova Conta")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                VStack(spacing: 16) {
                    TextField("Nome de usuário", text: $viewModel.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    TextField("E-mail", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    SecureInputView(title: "Senha", text: $viewModel.password)
                    
                    SecureInputView(title: "Confirmar Senha", text: $viewModel.confirmPassword)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    Task { await viewModel.register() }
                }) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Cadastrar")
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
                .padding(.top, 10)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sucesso!", isPresented: $viewModel.isRegisteredSuccessfully) {
            Button("Ir para Login") {
                dismiss()
            }
        } message: {
            Text("Sua conta foi criada com sucesso. Faça login para continuar.")
        }
    }
}
