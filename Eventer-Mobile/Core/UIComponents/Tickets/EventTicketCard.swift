import SwiftUI

struct EventTicketCard: View {
    let ticket: TicketResponseDto
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                if let imageUrl = ticket.eventCoverImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color.accentColor.opacity(0.2)
                    }
                } else {
                    Color.accentColor.opacity(0.2)
                }
                
                LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.eventTitle)
                        .padding(.bottom, 10)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(ticket.ticketTypeName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }
                .padding(16)
            }
            .frame(height: 140)
            .overlay(alignment: .topTrailing) {
                TicketStatusBadge(status: ticket.status)
                    .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(12)
            
            HStack(spacing: 0) {
                Circle().fill(Color(.systemGroupedBackground)).frame(width: 24, height: 24).offset(x: -12)
                Line().stroke(style: StrokeStyle(lineWidth: 1.5, dash: [6])).frame(height: 1).foregroundColor(Color(.systemGray4))
                Circle().fill(Color(.systemGroupedBackground)).frame(width: 24, height: 24).offset(x: 12)
            }
            .background(Color(.systemBackground))
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DATA").font(.caption2).fontWeight(.bold).foregroundColor(.secondary)
                        Text(formatDate(ticket.eventStartDate)).font(.subheadline).fontWeight(.medium)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("LOCAL").font(.caption2).fontWeight(.bold).foregroundColor(.secondary)
                        Text(ticket.eventLocation).font(.subheadline).fontWeight(.medium).lineLimit(1)
                    }
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TITULAR").font(.caption2).fontWeight(.bold).foregroundColor(.secondary)
                        Text(ticket.safeAttendeeName).font(.footnote).fontWeight(.semibold).lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("PEDIDO").font(.caption2).fontWeight(.bold).foregroundColor(.secondary)
                        Text(ticket.id.prefix(8).uppercased()).font(.footnote).fontWeight(.semibold)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 20)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
        .padding(.horizontal, 20)
    }
    
    private func formatDate(_ isoString: String?) -> String {
        guard let iso = isoString else { return "--/--" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let date = formatter.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
        guard let validDate = date else { return "--/--" }
        
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd/MM • HH:mm"
        return f.string(from: validDate)
    }
}
