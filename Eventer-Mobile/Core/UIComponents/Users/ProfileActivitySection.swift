import SwiftUI

struct ProfileActivitySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Atividades")
                .font(.headline)
                .padding(.horizontal, 8)
            
            NavigationLink(destination: OrderHistoryView()) {
                HStack(spacing: 16) {
                    Image(systemName: "bag.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                    
                    Text("Histórico de Pedidos")
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
}
