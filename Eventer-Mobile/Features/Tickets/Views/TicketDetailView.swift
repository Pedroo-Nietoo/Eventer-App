import SwiftUI

struct TicketDetailView: View {
    @StateObject private var viewModel: TicketDetailViewModel
    
    init(ticket: TicketResponseDto) {
        _viewModel = StateObject(wrappedValue: TicketDetailViewModel(initialTicket: ticket))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        TicketStatusBadge(status: viewModel.ticket.status)
                            .scaleEffect(1.1)
                            .padding(.bottom, 4)
                        
                        Text(viewModel.ticket.eventTitle)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        qrCodeSection
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    
                    HStack(spacing: 0) {
                        Circle()
                            .fill(Color(.systemGroupedBackground))
                            .frame(width: 40, height: 40)
                            .offset(x: -20)
                        
                        Line()
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .frame(height: 1)
                            .foregroundColor(Color(.systemGray3))
                        
                        Circle()
                            .fill(Color(.systemGroupedBackground))
                            .frame(width: 40, height: 40)
                            .offset(x: 20)
                    }
                    .background(Color(.systemBackground))
                    
                    VStack(spacing: 0) {
                        ElegantDetailRow(icon: "person.fill", title: "Titular do Ingresso", value: viewModel.ticket.safeAttendeeName)
                        Divider().padding(.leading, 56)
                        
                        ElegantDetailRow(icon: "ticket.fill", title: "Tipo de Ingresso", value: viewModel.ticket.ticketTypeName)
                        Divider().padding(.leading, 56)
                        
                        ElegantDetailRow(icon: "calendar", title: "Data e Hora", value: formatEventDateRange(start: viewModel.ticket.eventStartDate, end: viewModel.ticket.eventEndDate))
                        Divider().padding(.leading, 56)
                        
                        ElegantDetailRow(icon: "mappin.and.ellipse", title: "Local", value: viewModel.ticket.eventLocation)
                        Divider().padding(.leading, 56)
                        
                        ElegantDetailRow(icon: "number", title: "Número do Pedido", value: viewModel.ticket.id.prefix(8).uppercased())
                    }
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.08), radius: 25, y: 12)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Ingresso")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refreshTicket()
        }
    }
    
    @ViewBuilder
    private var qrCodeSection: some View {
        if viewModel.ticket.status == .used {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.green)
                Text("Ingresso Utilizado")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            .frame(height: 240)
        } else if viewModel.ticket.status == .cancelled {
            VStack(spacing: 16) {
                Image(systemName: "xmark.seal.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.red)
                Text("Ingresso Cancelado")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
            .frame(height: 240)
        } else if viewModel.isQRUnlocked {
            VStack(spacing: 12) {
                Image(uiImage: QRCodeGenerator.generate(from: viewModel.ticket.qrCodeData))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                
                Text("Apresente este código na entrada")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        } else {
            VStack(spacing: 12) {
                ZStack {
                    Image(uiImage: QRCodeGenerator.generate(from: "LOCKED_QR_CODE_MOCK_DATA"))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .blur(radius: 8)
                        .opacity(0.3)
                    
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.black.opacity(0.7))
                        
                        Text("Em breve")
                            .font(.headline)
                            .foregroundColor(.black.opacity(0.7))
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                
                Text("O QR Code será liberado\n12 horas antes do evento.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formatEventDateRange(start: String?, end: String?) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let startIso = start,
              let startDate = isoFormatter.date(from: startIso) ?? ISO8601DateFormatter().date(from: startIso)
        else { return "Data a definir" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "dd 'de' MMM, yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        var result = "\(dateFormatter.string(from: startDate)) • \(timeFormatter.string(from: startDate))"
        
        if let endIso = end, let endDate = isoFormatter.date(from: endIso) ?? ISO8601DateFormatter().date(from: endIso) {
            result += " às \(timeFormatter.string(from: endDate))"
        }
        
        return result
    }
}
