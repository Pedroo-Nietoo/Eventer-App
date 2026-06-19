import SwiftUI

struct CheckoutView: View {
    @StateObject var viewModel: CheckoutViewModel
    @Environment(\.dismiss) var dismiss
    
    init(ticket: TicketType) {
        _viewModel = StateObject(wrappedValue: CheckoutViewModel(ticket: ticket))
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .reviewing, .loading:
                    CheckoutReviewView(viewModel: viewModel)
                case .paying(let url):
                    StripeWebView(url: url, onSuccess: {
                        viewModel.handlePaymentSuccess()
                    }, onCancel: {
                        viewModel.handlePaymentCancel()
                    })
                    .ignoresSafeArea(edges: .bottom)
                case .success:
                    PaymentSuccessView { dismiss() }
                case .failed:
                    PaymentFailedView(onRetry: { viewModel.state = .reviewing }, onCancel: { dismiss() })
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if case .reviewing = viewModel.state {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancelar") { dismiss() }
                    }
                }
            }
        }
    }
    
    private var navigationTitle: String {
        switch viewModel.state {
        case .reviewing, .loading: return "Revisar Pedido"
        case .paying: return "Pagamento Seguro"
        case .success, .failed: return ""
        }
    }
}
