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
                    EventDetailHeaderImage(imageUrl: event.coverImageUrl)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        EventDetailTitleSection(title: event.title, description: event.description)
                        
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
                        
                        EventRulesSection(requiresDocument: event.requiresDocument, isAgeRestricted: event.isAgeRestricted)
                        
                        EventTicketsSection(viewModel: viewModel)
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
            
            BackButton(action: { dismiss() })
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            EventDetailBottomBar(
                isTicketSelected: viewModel.selectedTicket != nil,
                onMapTap: openAppleMaps,
                onCheckoutTap: { if viewModel.selectedTicket != nil { showCheckoutSheet = true } }
            )
        }
        .onAppear { Task { await viewModel.loadTickets(for: event.id) } }
        .sheet(isPresented: $showCheckoutSheet) {
            if let ticket = viewModel.selectedTicket {
                CheckoutView(ticket: ticket)
            }
        }
    }
    
    private func openAppleMaps() {
        guard let lat = event.location?.latitude, let lng = event.location?.longitude else { return }
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = event.locationName.isEmpty ? event.title : event.locationName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
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
