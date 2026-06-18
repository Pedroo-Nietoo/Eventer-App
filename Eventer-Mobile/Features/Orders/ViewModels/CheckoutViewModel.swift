import Foundation
import Combine

struct AttendeeForm: Identifiable {
    let id = UUID()
    var name: String = ""
}

enum CheckoutState: Equatable {
    case reviewing
    case loading
    case paying(URL)
    case success
    case failed
}

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var ticket: TicketType
    @Published var quantity: Int = 1 {
        didSet { adjustAttendees() }
    }
    @Published var attendees: [AttendeeForm] = [AttendeeForm()]
    @Published var state: CheckoutState = .reviewing
    @Published var errorMessage: String?
    
    private let repository: OrderRepositoryProtocol
    
    var totalPrice: Double {
        return ticket.price * Double(quantity)
    }
    
    var isFormValid: Bool {
        return attendees.allSatisfy { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    init(ticket: TicketType, repository: OrderRepositoryProtocol = OrderRepository()) {
        self.ticket = ticket
        self.repository = repository
    }
    
    private func adjustAttendees() {
        if attendees.count < quantity {
            let difference = quantity - attendees.count
            for _ in 0..<difference { attendees.append(AttendeeForm()) }
        } else if attendees.count > quantity {
            attendees.removeLast(attendees.count - quantity)
        }
    }
    
    func initiateCheckout() async {
        guard isFormValid else {
            errorMessage = "Preencha o nome de todos os participantes."
            return
        }
        
        state = .loading
        errorMessage = nil
        
        let attendeeNames = attendees.map { $0.name.trimmingCharacters(in: .whitespacesAndNewlines) }
        let dto = CreateOrderRequestDto(ticketTypeId: ticket.id, quantity: quantity, attendees: attendeeNames)
        
        do {
            let response = try await repository.createOrder(dto: dto)
            if let url = URL(string: response.checkoutUrl) {
                state = .paying(url)
            } else {
                state = .failed
            }
        } catch {
            errorMessage = "Falha ao processar pedido. Tente novamente."
            state = .reviewing
        }
    }
    
    func handlePaymentSuccess() {
        state = .success
    }
    
    func handlePaymentCancel() {
        state = .failed
    }
}
