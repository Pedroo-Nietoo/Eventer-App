import SwiftUI

struct CheckoutReviewView: View {
    @ObservedObject var viewModel: CheckoutViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    CheckoutTicketSummarySection(viewModel: viewModel)
                    CheckoutAttendeesSection(viewModel: viewModel)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding()
            }
            
            CheckoutBottomBar(viewModel: viewModel)
        }
    }
}

struct CheckoutTicketSummarySection: View {
    @ObservedObject var viewModel: CheckoutViewModel
    
    var body: some View {
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
    }
}

struct CheckoutAttendeesSection: View {
    @ObservedObject var viewModel: CheckoutViewModel
    
    var body: some View {
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
    }
}

struct CheckoutBottomBar: View {
    @ObservedObject var viewModel: CheckoutViewModel
    
    var body: some View {
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
