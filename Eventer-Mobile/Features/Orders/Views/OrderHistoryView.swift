import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderHistoryViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.orders.isEmpty {
                VStack(spacing: 16) {
                    ProgressView().scaleEffect(1.5)
                    Text("Carregando histórico...").foregroundColor(.secondary)
                }
            } else if viewModel.orders.isEmpty {
                ContentUnavailableView(
                    "Nenhum pedido",
                    systemImage: "bag",
                    description: Text("Você ainda não realizou nenhum pedido.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.orders) { order in
                            NavigationLink(destination: OrderDetailView(order: order, onRefresh: {
                                Task { await viewModel.refreshOrders() }
                            })) {
                                OrderCardView(order: order)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if viewModel.canLoadMore {
                            ProgressView()
                                .padding(.vertical, 20)
                                .onAppear {
                                    Task { await viewModel.loadMoreOrders() }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .navigationTitle("Histórico de Pedidos")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.orders.isEmpty {
                await viewModel.refreshOrders()
            }
        }
    }
}

struct OrderCardView: View {
    let order: OrderResponseDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(formatDate(order.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                StatusBadge(status: order.status)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Pedido: \(order.id.prefix(8).uppercased())")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(order.quantity)x Ingresso(s)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
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
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
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

struct StatusBadge: View {
    let status: OrderStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15))
            .clipShape(Capsule())
    }
    
    private var statusText: String {
        switch status {
        case .pending: return "PENDENTE"
        case .paid: return "PAGO"
        case .failed: return "FALHOU"
        case .canceled: return "CANCELADO"
        case .expired: return "EXPIRADO"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .paid: return .green
        case .failed, .canceled: return .red
        case .expired: return .gray
        }
    }
}
