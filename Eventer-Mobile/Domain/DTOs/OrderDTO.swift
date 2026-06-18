import Foundation

enum OrderStatus: String, Codable {
    case pending = "PENDING"
    case paid = "PAID"
    case failed = "FAILED"
    case canceled = "CANCELED"
    case expired = "EXPIRED"
}

struct CreateOrderRequestDto: Codable {
    let ticketTypeId: String
    let quantity: Int
    let attendees: [String]
}

struct CreateOrderResponseDto: Codable {
    let orderId: String
    let checkoutUrl: String
}

struct OrderResponseDto: Codable, Identifiable {
    let id: String
    let userId: String
    let ticketTypeId: String
    let quantity: Int
    let unitPrice: Double
    let totalPrice: Double
    let attendeeNames: [String]
    let status: OrderStatus
    let createdAt: String
    let updatedAt: String
    let checkoutUrl: String?
}
