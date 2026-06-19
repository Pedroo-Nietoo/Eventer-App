import SwiftUI

struct RegisterActionsView: View {
    @ObservedObject var viewModel: RegisterViewModel
    
    var body: some View {
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
    }
}
