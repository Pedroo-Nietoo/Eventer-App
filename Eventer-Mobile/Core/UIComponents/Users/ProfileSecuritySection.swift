import SwiftUI

struct ProfileSecuritySection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Segurança")
                .font(.headline)
                .padding(.horizontal, 8)
            
            VStack(spacing: 12) {
                SecureInputView(title: "Nova Senha", text: $viewModel.newPassword)
                SecureInputView(title: "Confirmar Nova Senha", text: $viewModel.confirmPassword)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(viewModel.errorMessage != nil ? Color.red : Color.clear, lineWidth: 1)
            )
        }
    }
}
