import SwiftUI
import PhotosUI

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
                        
                        VStack(spacing: 12) {
                            PhotosPicker(selection: $viewModel.selectedImageItem, matching: .images, photoLibrary: .shared()) {
                                ZStack(alignment: .bottomTrailing) {
                                    Group {
                                        if let imageData = viewModel.selectedImageData, let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage).resizable().scaledToFill()
                                        } else if let imageUrl = viewModel.currentProfileImageUrl, let url = URL(string: imageUrl) {
                                            AsyncImage(url: url) { image in image.resizable().scaledToFill() } placeholder: { ProgressView() }
                                        } else {
                                            Image(systemName: "person.crop.circle.fill").resizable().foregroundColor(Color(.systemGray3))
                                        }
                                    }
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                                    
                                    Image(systemName: "camera.circle.fill")
                                        .resizable()
                                        .frame(width: 36, height: 36)
                                        .foregroundColor(.accentColor)
                                        .background(Color(.systemBackground))
                                        .clipShape(Circle())
                                }
                            }
                            .onChange(of: viewModel.selectedImageItem) { _ in viewModel.processSelectedImage() }
                            
                            Text("Alterar foto de perfil")
                                .font(.footnote)
                                .foregroundColor(.accentColor)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Dados Pessoais")
                                .font(.headline)
                                .padding(.horizontal, 8)
                            
                            VStack(spacing: 0) {
                                ReadOnlyRow(title: "Nome de Usuário", value: viewModel.currentUser?.username ?? "Carregando...")
                                Divider()
                                ReadOnlyRow(title: "E-mail", value: viewModel.currentUser?.email ?? "Carregando...")
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "info.circle.fill").foregroundColor(.secondary)
                                Text("Dados imutáveis. Entre em contato com o suporte para alterações.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                        }
                        
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
                        
                        Button(action: { showConfirmationModal = true }) {
                            ZStack {
                                if viewModel.isLoading { ProgressView().tint(.white) }
                                else { Text("Salvar Alterações").fontWeight(.semibold) }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((viewModel.newPassword.isEmpty && viewModel.selectedImageData == nil) ? Color.gray.opacity(0.5) : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading || (viewModel.newPassword.isEmpty && viewModel.selectedImageData == nil))
                        
                        Button(action: { sessionManager.logout() }) {
                            Text("Sair da Conta")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
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
            } message: { Text("Seus dados foram atualizados com sucesso.") }
        }
    }
}

struct ReadOnlyRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
    }
}
