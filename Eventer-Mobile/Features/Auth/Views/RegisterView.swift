import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                RegisterHeaderView()
                    .padding(.bottom, 10)
                
                RegisterFormView(viewModel: viewModel)
                
                RegisterActionsView(viewModel: viewModel)
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
