import SwiftUI
import MapKit

struct EventsMapView: View {
    @StateObject private var viewModel = EventsMapViewModel()
    @EnvironmentObject var sessionManager: AppSessionManager
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var sheetHeight: CGFloat = 400
    @GestureState private var dragOffset: CGFloat = 0
    
    @State private var selectedEventId: String?
    @State private var eventToNavigate: Event?
    
    var selectedEvent: Event? {
        viewModel.nearbyEvents.first { $0.id == selectedEventId }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                Map(position: $cameraPosition, selection: $selectedEventId) {
                    UserAnnotation()
                    ForEach(viewModel.nearbyEvents, id: \.id) { event in
                        Marker(event.title, coordinate: CLLocationCoordinate2D(
                            latitude: event.location?.latitude ?? 0,
                            longitude: event.location?.longitude ?? 0
                        ))
                        .tint(Color.accentColor)
                        .tag(event.id)
                    }
                }
                .mapControls {
                    MapCompass()
                }
                
                VStack {
                    HStack(alignment: .top) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.radiusOptions, id: \.self) { radius in
                                    Button(action: {
                                        viewModel.updateRadius(radius)
                                        selectedEventId = nil
                                    }) {
                                        Text("\(Int(radius / 1000)) km")
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(viewModel.currentRadius == radius ? Color.accentColor : Color(.systemBackground))
                                            .foregroundColor(viewModel.currentRadius == radius ? .white : .primary)
                                            .clipShape(Capsule())
                                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 60)
                        }
                    }
                    Spacer()
                }
                
                if let event = selectedEvent {
                    VStack {
                        Spacer()
                        MapPreviewCard(event: event, onClose: {
                            selectedEventId = nil
                        }, onTap: {
                            eventToNavigate = event
                        })
                        .padding(.horizontal, 20)
                        .padding(.bottom, max(200, sheetHeight - dragOffset) + 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(1)
                }
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Spacer()
                            Capsule()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 40, height: 5)
                            Spacer()
                        }
                        .padding(.top, 12)
                        
                        HStack {
                            Text("Explore locais perto de você")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 12)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.height
                            }
                            .onEnded { value in
                                let dragAmount = value.translation.height
                                let targetHeight = sheetHeight - dragAmount
                                
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    if targetHeight > UIScreen.main.bounds.height * 0.65 {
                                        sheetHeight = UIScreen.main.bounds.height - 150
                                    } else if targetHeight > 250 {
                                        sheetHeight = 400
                                    } else {
                                        sheetHeight = 200
                                    }
                                }
                            }
                    )
                    
                    EventListSheetView(events: viewModel.nearbyEvents, isLoading: viewModel.isLoading)
                }
                .frame(height: max(200, sheetHeight - dragOffset))
                .background(.regularMaterial)
                .clipShape(CustomSheetCorners(radius: 24, corners: [.topLeft, .topRight]))
                .shadow(color: .black.opacity(0.15), radius: 8, y: -4)
                .zIndex(0)
            }
            .animation(.spring(), value: selectedEventId)
            .ignoresSafeArea(edges: .all)
            .onAppear {
                viewModel.startTracking()
            }
            .navigationDestination(item: $eventToNavigate) { event in
                EventDetailView(event: event)
            }
        }
    }
}

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

struct CustomSheetCorners: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
