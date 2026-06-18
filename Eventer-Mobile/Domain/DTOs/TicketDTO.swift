import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins
enum TicketStatus: String, Codable {
    case valid = "VALID"
    case used = "USED"
    case cancelled = "CANCELLED"
}
struct TicketResponseDto: Codable, Identifiable {
    let id: String
    let qrCode: String
    let status: TicketStatus
    let attendeeName: String?
    let purchasePrice: Double?
    let createdAt: String
    let user: TicketUserDto
    let ticketType: TicketTypeNestedDto
    
    var eventId: String { ticketType.event.id }
    var eventTitle: String { ticketType.event.title }
    var eventCoverImageUrl: String? { ticketType.event.coverImageUrl }
    var eventStartDate: String? { ticketType.event.eventStartDate }
    var eventEndDate: String? { ticketType.event.eventEndDate }
    var eventLocation: String { ticketType.event.locationName ?? "Local a definir" }
    var ticketTypeName: String { ticketType.name ?? "Ingresso" }
    var qrCodeData: String { qrCode }
    
    var safeAttendeeName: String {
        return attendeeName ?? user.username ?? "Não informado"
    }
}
struct TicketUserDto: Codable {
    let id: String
    let username: String?
    let email: String?
}
struct TicketTypeNestedDto: Codable {
    let id: String
    let name: String?
    let price: Double?
    let event: TicketEventNestedDto
}
struct TicketEventNestedDto: Codable {
    let id: String
    let title: String
    let coverImageUrl: String?
    let eventStartDate: String?
    let eventEndDate: String?
    let locationName: String?
}
enum QRCodeGenerator {
    static func generate(from string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return UIImage(systemName: "qrcode") ?? UIImage()
    }
}
