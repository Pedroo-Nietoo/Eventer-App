import SwiftUI

struct MapPreviewCard: View {
    let event: Event
    let onClose: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: event.coverImageUrl ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color(uiColor: .systemGray5)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 10))
                        Text(formatDate(event.eventStartDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 10))
                        Text(event.locationName.isEmpty ? event.address : event.locationName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 2)
                
                Spacer(minLength: 0)
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(.systemGray3))
                }
                .padding(.top, 4)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: isoString) ?? ISO8601DateFormatter().date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "pt_BR")
            displayFormatter.dateFormat = "dd/MM • HH:mm"
            return displayFormatter.string(from: date)
        }
        return "Data indisponível"
    }
}
