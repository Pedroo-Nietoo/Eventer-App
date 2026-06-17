import SwiftUI

struct EventListView: View {
    @StateObject private var viewModel = EventListViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.events.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Buscando eventos...")
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.events.isEmpty && !viewModel.searchText.isEmpty {
                    ContentUnavailableView(
                        "Nenhum evento encontrado",
                        systemImage: "magnifyingglass",
                        description: Text("Não encontramos resultados para \"\(viewModel.searchText)\".")
                    )
                } else if viewModel.events.isEmpty {
                    ContentUnavailableView(
                        "Sem Eventos",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Nenhum evento disponível no momento.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.events) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventRowView(event: event)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if viewModel.canLoadMore {
                                ProgressView()
                                    .padding(.vertical, 20)
                                    .onAppear {
                                        Task {
                                            await viewModel.loadMoreEvents()
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    .scrollDismissesKeyboard(.interactively)
                }
            }
            .navigationTitle("Eventos")
            .searchable(text: $viewModel.searchText, prompt: "Buscar por nome, descrição ou local...")
            .task {
                if viewModel.events.isEmpty {
                    await viewModel.refreshEvents()
                }
            }
        }
    }
}
