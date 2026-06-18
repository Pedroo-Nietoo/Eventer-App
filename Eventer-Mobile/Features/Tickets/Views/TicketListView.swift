import SwiftUI
import CoreImage.CIFilterBuiltins
struct TicketListView: View {
    @StateObject private var viewModel = TicketListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.tickets.isEmpty {
                    ProgressView().scaleEffect(1.5)
                } else if viewModel.tickets.isEmpty {
                    ContentUnavailableView(
                        "Nenhum ingresso",
                        systemImage: "ticket.fill",
                        description: Text("Você ainda não possui ingressos para nenhum evento.")
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.tickets) { ticket in
                                NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                                    BoardingPassTicketCard(ticket: ticket)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if viewModel.canLoadMore {
                                ProgressView()
                                    .padding(.vertical, 20)
                                    .onAppear { Task { await viewModel.loadMore() } }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .refreshable {
                        await viewModel.refreshTickets()
                    }
                }
            }
            .navigationTitle("Meus Ingressos")
            .task {
                if viewModel.tickets.isEmpty {
                    await viewModel.refreshTickets()
                }
            }
        }
    }
}
struct BoardingPassTicketCard: View {
    let ticket: TicketResponseDto
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 20) {
                HStack(alignment: .top) {
                    HStack(spacing: 8) {
                        Image(systemName: "ticket.fill")
                            .foregroundColor(.accentColor)
                        Text(ticket.eventTitle)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                    }
                    Spacer()
                    TicketStatusBadge(status: ticket.status)
                }
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(getTime(from: ticket.eventStartDate))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text(getShortDate(from: ticket.eventStartDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 6) {
                        Text(ticket.ticketTypeName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Circle().frame(width: 4, height: 4).foregroundColor(Color(.systemGray4))
                            Line().stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4])).frame(height: 1).foregroundColor(Color(.systemGray4)).frame(width: 40)
                            Image(systemName: "mappin.circle.fill").foregroundColor(.accentColor).font(.caption)
                            Line().stroke(style: StrokeStyle(lineWidth: 1.5, dash: [4])).frame(height: 1).foregroundColor(Color(.systemGray4)).frame(width: 40)
                            Circle().frame(width: 4, height: 4).foregroundColor(Color(.systemGray4))
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(getTime(from: ticket.eventEndDate))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text(getShortDate(from: ticket.eventEndDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(20)
            
            HStack(spacing: 0) {
                Circle()
                    .fill(Color(.systemGroupedBackground))
                    .frame(width: 24, height: 24)
                    .offset(x: -12)
                
                Line()
                    .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [5]))
                    .frame(height: 1)
                    .foregroundColor(Color(.systemGray4))
                
                Circle()
                    .fill(Color(.systemGroupedBackground))
                    .frame(width: 24, height: 24)
                    .offset(x: 12)
            }
            
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TITULAR")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text(ticket.safeAttendeeName)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("LOCAL")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    Text(ticket.eventLocation)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(.systemGray6).opacity(0.3))
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 6)
        .padding(.horizontal, 20)
    }
    
    private func getTime(from isoString: String?) -> String {
        guard let iso = isoString, let date = ISO8601DateFormatter().date(from: iso) else { return "--:--" }
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
    
    private func getShortDate(from isoString: String?) -> String {
        guard let iso = isoString, let date = ISO8601DateFormatter().date(from: iso) else { return "A definir" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "dd MMM"
        return f.string(from: date).uppercased()
    }
}
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
        guard let startIso = start, let startDate = ISO8601DateFormatter().date(from: startIso) else { return "Data a definir" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "pt_BR")
        dateFormatter.dateFormat = "dd 'de' MMM, yyyy"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        var result = "\(dateFormatter.string(from: startDate)) • \(timeFormatter.string(from: startDate))"
        
        if let endIso = end, let endDate = ISO8601DateFormatter().date(from: endIso) {
            result += " às \(timeFormatter.string(from: endDate))"
        }
        
        return result
    }
}
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
            .foregroundColor(statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.15))
            .clipShape(Capsule())
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
