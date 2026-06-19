import SwiftUI

struct ProfilePersonalDataSection: View {
    let user: UserResponseDto?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dados Pessoais")
                .font(.headline)
                .padding(.horizontal, 8)
            
            VStack(spacing: 0) {
                ReadOnlyRow(title: "Nome de Usuário", value: user?.username ?? "Carregando...")
                Divider()
                ReadOnlyRow(title: "E-mail", value: user?.email ?? "Carregando...")
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
    }
}
