import SwiftUI

struct RegisterFormView: View {
    @ObservedObject var viewModel: RegisterViewModel
    
    var body: some View {
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
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
