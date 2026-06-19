import SwiftUI
import PhotosUI

struct ProfilePhotoSection: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $viewModel.selectedImageItem, matching: .images, photoLibrary: .shared()) {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let imageData = viewModel.selectedImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage).resizable().scaledToFill()
                        } else if let imageUrl = viewModel.currentProfileImageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in 
                                image.resizable().scaledToFill() 
                            } placeholder: { 
                                ProgressView() 
                            }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .foregroundColor(Color(.systemGray3))
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
    }
}
