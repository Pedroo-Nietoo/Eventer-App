import SwiftUI

struct OrderCardView: View {
    let order: OrderResponseDto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(formatDate(order.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                OrderStatusBadge(status: order.status)
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
