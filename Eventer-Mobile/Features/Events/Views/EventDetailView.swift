import SwiftUI
import MapKit

struct EventDetailView: View {
    let event: Event
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionManager: AppSessionManager
    @StateObject private var viewModel = EventDetailViewModel()
    
    @State private var showCheckoutSheet = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    AsyncImage(url: URL(string: event.coverImageUrl ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFill()
                        } else {
                            Color(uiColor: .systemGray5)
                                .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 320)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.title)
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            if let desc = event.description, !desc.isEmpty {
                                Text(desc)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                        }
                        
                        SectionView(title: "Data e Hora") {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(icon: "calendar.badge.clock", text: "Início: \(formatDateTime(event.eventStartDate))")
                                InfoRow(icon: "calendar.badge.clock", text: "Término: \(formatDateTime(event.eventEndDate))")
                            }
                        }
                        
                        SectionView(title: "Localização") {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(icon: "mappin.and.ellipse", text: event.locationName.isEmpty ? event.address : "\(event.locationName)\n\(event.address)")
                            }
                        }
                        
                        SectionView(title: "Regulamento") {
                            VStack(alignment: .leading, spacing: 12) {
                                if event.requiresDocument {
                                    InfoRow(icon: "person.text.rectangle", text: "Obrigatório apresentar documento oficial com foto.")
                                } else {
                                    InfoRow(icon: "person.text.rectangle", text: "Não é exigida apresentação de documento.")
                                }
                                
                                if event.isAgeRestricted {
                                    InfoRow(icon: "18.circle", text: "Válido apenas para maiores de 18 anos.")
                                } else {
                                    InfoRow(icon: "checkmark.circle", text: "Livre para todas as idades.")
                                }
                            }
                        }
                        
                        SectionView(title: "Ingressos") {
                            if viewModel.isLoadingTickets {
                                HStack {
                                    Spacer()
                                    ProgressView("Buscando ingressos...")
                                    Spacer()
                                }
                                .padding(.vertical)
                            } else if viewModel.ticketTypes.isEmpty {
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.orange)
                                    Text("Ingressos ainda não liberados")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.orange)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.orange.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                VStack(spacing: 12) {
                                    ForEach(viewModel.ticketTypes) { ticket in
                                        TicketCardView(
                                            ticket: ticket,
                                            isSelected: viewModel.selectedTicket?.id == ticket.id
                                        ) {
                                            viewModel.selectTicket(ticket)
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(TopCornerShape(radius: 32))
                    .offset(y: -40)
                    .padding(.bottom, -40)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            }
            .padding(.leading, 20)
            .padding(.top, 10)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .onAppear {
            Task {
                await viewModel.loadTickets(for: event.id)
            }
        }
        .sheet(isPresented: $showCheckoutSheet) {
            if let ticket = viewModel.selectedTicket {
                CheckoutView(ticket: ticket)
            }
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 16) {
                Button(action: openAppleMaps) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                Button(action: {
                    if viewModel.selectedTicket != nil {
                        showCheckoutSheet = true
                    }
                }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Garantir Ingresso")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(viewModel.selectedTicket == nil ? Color.gray.opacity(0.5) : Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(viewModel.selectedTicket == nil)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private func openAppleMaps() {
        guard let lat = event.location?.latitude, let lng = event.location?.longitude else { return }
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event.locationName.isEmpty ? event.title : event.locationName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
    
    private func formatDateTime(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let date = formatter.date(from: isoString) ?? ISO8601DateFormatter().date(from: isoString)
        
        guard let validDate = date else { return isoString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "pt_BR")
        displayFormatter.dateFormat = "dd/MM/yyyy • HH:mm"
        
        return displayFormatter.string(from: validDate)
    }
}

struct TicketCardView: View {
    let ticket: TicketType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .accentColor : .gray.opacity(0.5))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if let desc = ticket.description, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Text(String(format: "R$ %.2f", ticket.price))
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .foregroundColor(.accentColor)
                        .padding(.top, 2)
                }
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TopCornerShape: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            content
        }
        .padding(.top, 12)
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
