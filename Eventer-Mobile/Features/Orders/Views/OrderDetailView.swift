import SwiftUI

struct URLWrapper: Identifiable {
    let id = UUID()
    let url: URL
}

struct OrderDetailView: View {
    let order: OrderResponseDto
    let onRefresh: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var paymentToResume: URLWrapper? = nil
    @State private var currentStatus: OrderStatus
    
    init(order: OrderResponseDto, onRefresh: @escaping () -> Void) {
        self.order = order
        self.onRefresh = onRefresh
        _currentStatus = State(initialValue: order.status)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                OrderDetailHeader(orderId: order.id, status: currentStatus)
                OrderPurchaseDetailsSection(order: order)
                OrderAttendeesSection(attendeeNames: order.attendeeNames)
                
                if currentStatus == .pending, let urlString = order.checkoutUrl, let url = URL(string: urlString) {
                    Button(action: { paymentToResume = URLWrapper(url: url) }) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                            Text("Finalizar Pagamento").fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Detalhes do Pedido")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $paymentToResume) { wrapper in
            StripeWebView(url: wrapper.url, onSuccess: {
                paymentToResume = nil
                currentStatus = .paid
                onRefresh()
            }, onCancel: {
                paymentToResume = nil
            })
            .ignoresSafeArea(edges: .bottom)
        }
    }
}
