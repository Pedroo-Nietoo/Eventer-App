import SwiftUI

struct ElegantDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

struct TicketStatusBadge: View {
    let status: TicketStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
    }
    
    private var statusText: String {
        switch status {
        case .valid: return "VÁLIDO"
        case .used: return "UTILIZADO"
        case .cancelled: return "CANCELADO"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .valid: return .accentColor
        case .used: return .green
        case .cancelled: return .red
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
