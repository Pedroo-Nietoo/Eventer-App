import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: AppSessionManager
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showConfirmationModal = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ProfilePhotoSection(viewModel: viewModel)
                            .padding(.top, 24)
                        
                        ProfileActivitySection()
                        
                        ProfilePersonalDataSection(user: viewModel.currentUser)
                        
                        ProfileSecuritySection(viewModel: viewModel)
                        
                        ProfileActionsSection(
                            viewModel: viewModel,
                            showConfirmationModal: $showConfirmationModal,
                            logoutAction: { sessionManager.logout() }
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Meu Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { Task { await viewModel.loadProfile() } }
            .alert("Salvar alterações?", isPresented: $showConfirmationModal) {
                Button("Cancelar", role: .cancel) { }
                Button("Confirmar") { Task { await viewModel.saveChanges() } }
            }
            .alert("Sucesso!", isPresented: $viewModel.showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Seus dados foram atualizados com sucesso.")
            }
        }
    }
}
