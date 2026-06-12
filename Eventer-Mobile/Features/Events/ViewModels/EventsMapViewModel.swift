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
    
    func updateRadius(_ radius: Double, token: String) {
        currentRadius = radius
        if let loc = locationManager.userLocation {
            Task {
                await fetchNearbyEvents(location: loc, token: token)
            }
        }
    }
    
    func fetchNearbyEvents(location: CLLocation, token: String) async {
        isLoading = true
        do {
            self.nearbyEvents = try await repository.fetchNearbyEvents(
                lat: location.coordinate.latitude,
                lng: location.coordinate.longitude,
                radius: currentRadius,
                token: token
            )
        } catch {
            self.nearbyEvents = []
        }
        isLoading = false
    }
    
    func startTracking(token: String) {
        locationManager.onLocationSignificantChange = { [weak self] location in
            Task { @MainActor in
                await self?.fetchNearbyEvents(location: location, token: token)
            }
        }
        requestLocation()
    }
}
