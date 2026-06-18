import SwiftUI

struct URLWrapper: Identifiable {
    let id = UUID()
    let url: URL
}

struct OrderDetailView: View {
    let order: OrderResponseDto
    let onRefresh: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var paymentToResume: URLWrapper? = nil
    @State private var currentStatus: OrderStatus
    
    init(order: OrderResponseDto, onRefresh: @escaping () -> Void) {
        self.order = order
        self.onRefresh = onRefresh
        _currentStatus = State(initialValue: order.status)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Código do Pedido")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(order.id.prefix(8).uppercased())
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    StatusBadge(status: currentStatus)
                }
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Detalhes da Compra")
                        .font(.headline)
                    
                    VStack(spacing: 0) {
                        ReadOnlyRow(title: "Data", value: formatDate(order.createdAt))
                        Divider()
                        ReadOnlyRow(title: "Quantidade", value: "\(order.quantity)x")
                        Divider()
                        ReadOnlyRow(title: "Valor Unitário", value: String(format: "R$ %.2f", order.unitPrice))
                        Divider()
                        HStack {
                            Text("Total")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(String(format: "R$ %.2f", order.totalPrice))
                                .font(.headline)
                                .foregroundColor(.accentColor)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(Color(.systemBackground))
                    }
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Participantes")
                        .font(.headline)
                    
                    VStack(spacing: 0) {
                        ForEach(Array(order.attendeeNames.enumerated()), id: \.offset) { index, name in
                            ReadOnlyRow(title: "Ingresso \(index + 1)", value: name)
                            if index < order.attendeeNames.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .cornerRadius(12)
                }
                
                if currentStatus == .pending, let urlString = order.checkoutUrl, let url = URL(string: urlString) {
                    Button(action: {
                        paymentToResume = URLWrapper(url: url)
                    }) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                            Text("Finalizar Pagamento")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Detalhes do Pedido")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $paymentToResume) { wrapper in
            StripeWebView(url: wrapper.url, onSuccess: {
                paymentToResume = nil
                currentStatus = .paid
                onRefresh()
            }, onCancel: {
                paymentToResume = nil
            })
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: isoString) ?? ISO8601DateFormatter().date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "pt_BR")
            displayFormatter.dateFormat = "dd/MM/yyyy • HH:mm"
            return displayFormatter.string(from: date)
        }
        return isoString
    }
}
