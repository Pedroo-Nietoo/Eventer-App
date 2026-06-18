import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var sessionManager: AppSessionManager
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                EventsMapView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Radar", systemImage: "map.fill")
            }
            
            EventListView()
                    .toolbar(.hidden, for: .navigationBar)
            .tabItem {
                Label("Eventos", systemImage: "calendar")
            }

            
            TicketListView()
                    .toolbar(.hidden, for: .navigationBar)
                .tabItem {
                    Label("Meus Ingressos", systemImage: "ticket")
                }
            
            ProfileView()
                    .toolbar(.hidden, for: .navigationBar)
            .tabItem {
                Label("Perfil", systemImage: "person.crop.circle")
            }
        }
    }
}
