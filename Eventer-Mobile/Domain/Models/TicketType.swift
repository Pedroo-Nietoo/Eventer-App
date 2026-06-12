import Foundation

struct TicketType: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let price: Double
}
