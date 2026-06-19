import SwiftUI

struct LoginHeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "ticket.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundColor(.accentColor)
            
            Text("Acesse sua conta")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
}
