import SwiftUI

struct EventListSheetView: View {
    let events: [Event]
    let isLoading: Bool
    
    var body: some View {
        Group {
            if events.isEmpty && !isLoading {
                VStack {
                    Spacer()
                    Text("Nenhum evento encontrado neste raio.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.bottom, 100)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(events) { event in
                            
                            EventRowView(event: event)
                                .overlay(
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        Color.clear
                                    }
                                )
                            
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
        }
    }
}
