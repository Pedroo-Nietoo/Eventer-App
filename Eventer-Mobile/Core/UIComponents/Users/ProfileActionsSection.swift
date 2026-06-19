import SwiftUI

struct ProfileActionsSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Binding var showConfirmationModal: Bool
    var logoutAction: () -> Void
    
    var isSaveDisabled: Bool {
        viewModel.isLoading || (viewModel.newPassword.isEmpty && viewModel.selectedImageData == nil)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: { showConfirmationModal = true }) {
                ZStack {
                    if viewModel.isLoading { 
                        ProgressView().tint(.white) 
                    } else { 
                        Text("Salvar Alterações").fontWeight(.semibold) 
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSaveDisabled ? Color.gray.opacity(0.5) : Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isSaveDisabled)
            
            Button(action: logoutAction) {
                Text("Sair da Conta")
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.bottom, 30)
        }
    }
}
