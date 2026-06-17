import SwiftUI
import MapKit

struct EventsMapView: View {
    @StateObject private var viewModel = EventsMapViewModel()
    @EnvironmentObject var sessionManager: AppSessionManager
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var sheetHeight: CGFloat = 400
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Map(position: $cameraPosition) {
                UserAnnotation()
                ForEach(viewModel.nearbyEvents, id: \.id) { event in
                    Marker(event.title, coordinate: CLLocationCoordinate2D(
                        latitude: event.location?.latitude ?? 0,
                        longitude: event.location?.longitude ?? 0
                    ))
                    .tint(Color.accentColor)
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
                        .padding(.top, 80)
                    }
                }
                Spacer()
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
        }
        .ignoresSafeArea(edges: .all)
        .onAppear {
            viewModel.startTracking()
        }
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
