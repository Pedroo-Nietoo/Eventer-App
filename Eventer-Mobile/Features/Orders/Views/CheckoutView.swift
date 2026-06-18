import SwiftUI

struct CheckoutView: View {
    @StateObject var viewModel: CheckoutViewModel
    @Environment(\.dismiss) var dismiss
    
    init(ticket: TicketType) {
        _viewModel = StateObject(wrappedValue: CheckoutViewModel(ticket: ticket))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .reviewing, .loading:
                    reviewContentView
                case .paying(let url):
                    StripeWebView(url: url, onSuccess: {
                        viewModel.handlePaymentSuccess()
                    }, onCancel: {
                        viewModel.handlePaymentCancel()
                    })
                    .ignoresSafeArea(edges: .bottom)
                case .success:
                    PaymentSuccessView { dismiss() }
                case .failed:
                    PaymentFailedView(onRetry: { viewModel.state = .reviewing }, onCancel: { dismiss() })
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if case .reviewing = viewModel.state {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancelar") { dismiss() }
                    }
                }
            }
        }
    }
    
    private var navigationTitle: String {
        switch viewModel.state {
        case .reviewing, .loading: return "Revisar Pedido"
        case .paying: return "Pagamento Seguro"
        case .success, .failed: return ""
        }
    }
    
    private var reviewContentView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingresso Selecionado")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.ticket.name)
                                    .fontWeight(.bold)
                                Text(String(format: "R$ %.2f", viewModel.ticket.price))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            Stepper("", value: $viewModel.quantity, in: 1...10)
                                .labelsHidden()
                            
                            Text("\(viewModel.quantity)x")
                                .fontWeight(.bold)
                                .frame(width: 30, alignment: .trailing)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Participantes")
                            .font(.headline)
                        
                        ForEach($viewModel.attendees) { $attendee in
                            if let index = viewModel.attendees.firstIndex(where: { $0.id == attendee.id }) {
                                TextField("Nome do participante \(index + 1)", text: $attendee.name)
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                        
                        Text("Os ingressos são nominais e intransferíveis.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding()
            }
            
            VStack(spacing: 16) {
                Divider()
                HStack {
                    Text("Total")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Text(String(format: "R$ %.2f", viewModel.totalPrice))
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.accentColor)
                }
                .padding(.horizontal)
                
                Button(action: { Task { await viewModel.initiateCheckout() } }) {
                    ZStack {
                        if case .loading = viewModel.state {
                            ProgressView().tint(.white)
                        } else {
                            Text("Ir para Pagamento")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.isFormValid ? Color.accentColor : Color.gray.opacity(0.5))
                    .cornerRadius(16)
                }
                .disabled(!viewModel.isFormValid || viewModel.state == .loading)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(Color(.systemBackground))
        }
    }
}

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
