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
    
    var selectedEvent: Event? { viewModel.nearbyEvents.first { $0.id == selectedEventId } }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $cameraPosition, selection: $selectedEventId) {
                    UserAnnotation()
                    ForEach(viewModel.nearbyEvents, id: \.id) { event in
                        Marker(event.title, coordinate: CLLocationCoordinate2D(latitude: event.location?.latitude ?? 0, longitude: event.location?.longitude ?? 0))
                            .tint(Color.accentColor).tag(event.id)
                    }
                }
                .mapControls { MapCompass() }
                
                VStack {
                    MapRadiusFilterView(radiusOptions: viewModel.radiusOptions, currentRadius: viewModel.currentRadius) { radius in
                        viewModel.updateRadius(radius)
                        selectedEventId = nil
                    }
                    Spacer()
                }
                
                if let event = selectedEvent {
                    VStack {
                        Spacer()
                        MapPreviewCard(event: event, onClose: { selectedEventId = nil }, onTap: { eventToNavigate = event })
                            .padding(.horizontal, 20)
                            .padding(.bottom, max(200, sheetHeight - dragOffset) + 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }.zIndex(1)
                }
                
                MapDraggableSheetView(
                    viewModel: viewModel,
                    sheetHeight: $sheetHeight,
                    dragOffset: dragOffset,
                    updatingGesture: dragOffset
                )
                .zIndex(0)
            }
            .animation(.spring(), value: selectedEventId)
            .ignoresSafeArea(edges: .all)
            .onAppear { viewModel.startTracking() }
            .navigationDestination(item: $eventToNavigate) { event in EventDetailView(event: event) }
        }
    }
}
