import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderHistoryViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.orders.isEmpty {
                VStack(spacing: 16) {
                    ProgressView().scaleEffect(1.5)
                    Text("Carregando histórico...").foregroundColor(.secondary)
                }
            } else if viewModel.orders.isEmpty {
                ContentUnavailableView(
                    "Nenhum pedido",
                    systemImage: "bag",
                    description: Text("Você ainda não realizou nenhum pedido.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.orders) { order in
                            NavigationLink(destination: OrderDetailView(order: order, onRefresh: {
                                Task { await viewModel.refreshOrders() }
                            })) {
                                OrderCardView(order: order)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        if viewModel.canLoadMore {
                            ProgressView()
                                .padding(.vertical, 20)
                                .onAppear {
                                    Task { await viewModel.loadMoreOrders() }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
        }
        .navigationTitle("Histórico de Pedidos")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.orders.isEmpty {
                await viewModel.refreshOrders()
            }
        }
    }
}
