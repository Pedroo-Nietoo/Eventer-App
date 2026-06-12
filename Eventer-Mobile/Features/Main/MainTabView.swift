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
            
            Text("Meus Ingressos")
                .tabItem {
                    Label("Ingressos", systemImage: "ticket")
                }
            
            NavigationStack {
                List {
                    Section(header: Text("Minha Conta")) {
                        Text(sessionManager.currentUserEmail ?? "Usuário")
                        Button("Sair da Conta", role: .destructive) {
                            sessionManager.logout()
                        }
                    }
                }
                .navigationTitle("Perfil")
            }
            .tabItem {
                Label("Perfil", systemImage: "person.crop.circle")
            }
        }
    }
}
