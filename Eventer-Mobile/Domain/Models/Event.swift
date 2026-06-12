import Foundation
import CoreLocation

struct Event: Codable, Identifiable {
    let id: String
    let organizerId: String
    let slug: String
    let title: String
    let description: String?
    let coverImageUrl: String?
    let isAgeRestricted: Bool
    let requiresDocument: Bool
    let eventStartDate: String
    let eventEndDate: String
    let locationName: String
    let address: String
    let location: LocationData?
    let createdAt: String
    
    struct LocationData: Codable {
        let latitude: Double
        let longitude: Double
        let distance: Double?
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let loc = location else { return nil }
        
        return CLLocationCoordinate2D(
            latitude: loc.latitude,
            longitude: loc.longitude
        )
    }
}
