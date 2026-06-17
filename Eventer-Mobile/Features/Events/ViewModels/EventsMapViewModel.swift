import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
class EventsMapViewModel: ObservableObject {
    @Published var nearbyEvents: [Event] = []
    @Published var currentRadius: Double = 3000
    @Published var isLoading = false
    
    let locationManager = LocationManager()
    private let repository: EventRepositoryProtocol
    
    let radiusOptions: [Double] = [3000, 5000, 10000]
    
    init(repository: EventRepositoryProtocol = EventRepository()) {
        self.repository = repository
    }
    
    func requestLocation() {
        locationManager.requestPermission()
    }
    
    func updateRadius(_ radius: Double) {
        currentRadius = radius
        if let loc = locationManager.userLocation {
            Task {
                await fetchNearbyEvents(location: loc)
            }
        }
    }
    
    func fetchNearbyEvents(location: CLLocation) async {
        isLoading = true
        do {
            self.nearbyEvents = try await repository.fetchNearbyEvents(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude,
                radius: currentRadius
            )
        } catch {
            self.nearbyEvents = []
        }
        isLoading = false
    }
    
    func startTracking() {
        locationManager.onLocationSignificantChange = { [weak self] location in
            Task { @MainActor in
                await self?.fetchNearbyEvents(location: location)
            }
        }
        requestLocation()
    }
}
