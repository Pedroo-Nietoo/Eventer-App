import SwiftUI

struct PaymentSuccessView: View {
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Pagamento Confirmado!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Seus ingressos já estão garantidos e foram enviados para o seu e-mail. Você também pode acessá-los na aba Meus Ingressos.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button("Concluir", action: onFinish)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.accentColor)
                .cornerRadius(16)
                .padding(.top, 24)
        }
        .padding(32)
    }
}

struct PaymentFailedView: View {
    let onRetry: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("Pagamento Não Concluído")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Houve um problema durante o pagamento ou a operação foi cancelada. Nenhum valor foi cobrado.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                Button("Tentar Novamente", action: onRetry)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accentColor)
                    .cornerRadius(16)
                
                Button("Cancelar", action: onCancel)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)
        }
        .padding(32)
    }
}
