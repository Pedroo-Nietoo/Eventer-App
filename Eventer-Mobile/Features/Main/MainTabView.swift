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

            
            Text("Meus Ingressos")
                .tabItem {
                    Label("Ingressos", systemImage: "ticket")
                }
            
            Text("Meus Pedidos")
                .tabItem {
                    Label("Pedidos", systemImage: "cart.fill")
                }
            
            ProfileView()
                    .toolbar(.hidden, for: .navigationBar)
            .tabItem {
                Label("Perfil", systemImage: "person.crop.circle")
            }
        }
    }
}
