import SwiftUI

struct OrderDetailHeader: View {
    let orderId: String
    let status: OrderStatus
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Código do Pedido")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(orderId.prefix(8).uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
            OrderStatusBadge(status: status)
        }
        .padding(.top, 16)
    }
}

struct OrderPurchaseDetailsSection: View {
    let order: OrderResponseDto
    
    var body: some View {
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

struct OrderAttendeesSection: View {
    let attendeeNames: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Participantes")
                .font(.headline)
            
            VStack(spacing: 0) {
                ForEach(Array(attendeeNames.enumerated()), id: \.offset) { index, name in
                    ReadOnlyRow(title: "Ingresso \(index + 1)", value: name)
                    if index < attendeeNames.count - 1 {
                        Divider()
                    }
                }
            }
            .cornerRadius(12)
        }
    }
}

struct OrderStatusBadge: View {
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
