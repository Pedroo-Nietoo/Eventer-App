import Foundation

struct TicketType: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let description: String?
    let price: Double
    let totalQuantity: Int?
    let availableQuantity: Int?
}
