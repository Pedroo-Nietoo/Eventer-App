import SwiftUI

struct LoginFormView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("E-mail", text: $viewModel.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            
            SecureInputView(title: "Senha", text: $viewModel.password)
            
            Toggle("Entrar com Biometria", isOn: $viewModel.enableBiometrics)
                .padding(.vertical, 8)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
