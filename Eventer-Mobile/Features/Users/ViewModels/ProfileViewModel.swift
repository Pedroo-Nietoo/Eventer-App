import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: UserResponseDto?
    
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    @Published var selectedImageItem: PhotosPickerItem?
    @Published var selectedImageData: Data?
    @Published var currentProfileImageUrl: String?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol = UserRepository()) {
        self.repository = repository
    }
    
    func loadProfile() async {
        isLoading = true
        do {
            self.currentUser = try await repository.getMyProfile()
            self.currentProfileImageUrl = currentUser?.profilePicture
        } catch {
            self.errorMessage = "Erro ao carregar dados do perfil."
        }
        isLoading = false
    }
    
    func processSelectedImage() {
        Task {
            if let data = try? await selectedImageItem?.loadTransferable(type: Data.self) {
                self.selectedImageData = data
            }
        }
    }
    
    func saveChanges() async {
        guard let userId = currentUser?.id else {
            self.errorMessage = "Erro interno: ID do usuário não encontrado."
            return
        }
        
        if !newPassword.isEmpty && newPassword != confirmPassword {
            self.errorMessage = "As senhas não coincidem."
            return
        }
        
        isLoading = true
        self.errorMessage = nil
        
        do {
            var finalImageUrl: String? = nil
            
            if let imageData = selectedImageData {
                let dto = PresignedUrlRequestDto(fileName: "profile.jpeg", contentType: "image/jpeg", folder: "users")
                let presignedData = try await repository.getPresignedUrl(dto: dto)
                
                try await repository.uploadToS3(
                    presignedUrl: presignedData.presignedUrl,
                    fields: presignedData.fields,
                    fileData: imageData,
                    mimeType: "image/jpeg",
                    fileName: "profile.jpeg"
                )
                
                finalImageUrl = presignedData.finalUrl
            }
            
            let passwordToUpdate = newPassword.isEmpty ? nil : newPassword
            let updateDto = UpdateProfileDto(password: passwordToUpdate, profilePicture: finalImageUrl)
            
            if passwordToUpdate != nil || finalImageUrl != nil {
                try await repository.updateProfile(userId: userId, dto: updateDto)
                
                if let newUrl = finalImageUrl {
                    self.currentProfileImageUrl = newUrl
                }
                
                self.newPassword = ""
                self.confirmPassword = ""
                self.selectedImageData = nil
                self.showSuccessAlert = true
            }
            
        } catch {
            self.errorMessage = "Falha ao salvar as alterações."
        }
        isLoading = false
    }
}
