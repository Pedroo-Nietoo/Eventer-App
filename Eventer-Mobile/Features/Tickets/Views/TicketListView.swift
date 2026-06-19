import SwiftUI

struct TicketListView: View {
    @StateObject private var viewModel = TicketListViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.tickets.isEmpty {
                    ProgressView().scaleEffect(1.5)
                } else if viewModel.tickets.isEmpty {
                    ContentUnavailableView(
                        "Nenhum ingresso",
                        systemImage: "ticket.fill",
                        description: Text("Você ainda não possui ingressos para nenhum evento.")
                    )
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.tickets) { ticket in
                                NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                                    EventTicketCard(ticket: ticket)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if viewModel.canLoadMore {
                                ProgressView()
                                    .padding(.vertical, 20)
                                    .onAppear { Task { await viewModel.loadMore() } }
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .refreshable {
                        await viewModel.refreshTickets()
                    }
                }
            }
            .navigationTitle("Meus Ingressos")
            .task {
                if viewModel.tickets.isEmpty {
                    await viewModel.refreshTickets()
                }
            }
        }
    }
}
