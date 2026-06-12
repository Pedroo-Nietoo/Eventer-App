import SwiftUI

struct EventDetailView: View {
    let event: Event
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sessionManager: AppSessionManager
    @StateObject private var viewModel = EventDetailViewModel()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    AsyncImage(url: URL(string: event.coverImageUrl ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFill()
                        } else {
                            Color(uiColor: .systemGray5)
                                .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
                        }
                    }
                    .frame(height: 320)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(event.title)
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                            if let desc = event.description, !desc.isEmpty {
                                Text(desc)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                            }
                        }
                        
                        if viewModel.isLoadingTickets {
                            HStack {
                                Spacer()
                                ProgressView("Carregando...")
                                Spacer()
                            }
                        } else if viewModel.ticketTypes.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "ticket.fill")
                                    .foregroundColor(.accentColor)
                                Text("Nenhum ingresso disponível.")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            VStack(spacing: 12) {
                                ForEach(viewModel.ticketTypes) { ticket in
                                    HStack(spacing: 12) {
                                        Image(systemName: "ticket.fill")
                                            .foregroundColor(.accentColor)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(ticket.name)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            Text(String(format: "R$ %.2f", ticket.price))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.accentColor.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        
                        SectionView(title: "Regulamento") {
                            VStack(alignment: .leading, spacing: 12) {
                                RuleRow(text: event.requiresDocument ? "Obrigatório apresentar documento oficial com foto." : "Não é exigida apresentação de documento.")
                                RuleRow(text: event.isAgeRestricted ? "Válido apenas para maiores de 18 anos." : "Livre para todas as idades.")
                                RuleRow(text: "Início: \(formatDate(event.eventStartDate))")
                            }
                        }
                        
                        SectionView(title: "Informações") {
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(icon: "mappin.and.ellipse", text: event.address)
                            }
                        }
                        
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground))
                    .clipShape(TopCornerShape(radius: 32))
                    .offset(y: -40)
                    .padding(.bottom, -40)
                }
            }
            .ignoresSafeArea(edges: .top)
            
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            }
            .padding(.leading, 20)
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .onAppear {
            if let token = sessionManager.token {
                Task { await viewModel.loadTickets(for: event.id, token: token) }
            }
        }
    }
    
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 16) {
                Button(action: { /* Ação do mapa, vai ser feito depois */ }) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                Button(action: { /* Ação de compra, vai ser feito depois */ }) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Garantir Ingresso")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground).shadow(color: .black.opacity(0.05), radius: 10, y: -5))
    }
    
    private func formatDate(_ isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: isoString) ?? ISO8601DateFormatter().date(from: isoString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "pt_BR")
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }
        return isoString
    }
}
struct TopCornerShape: Shape {
    var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            content
        }
        .padding(.top, 12)
    }
}
struct RuleRow: View {
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.secondary.opacity(0.5))
                .frame(width: 4, height: 4)
                .padding(.top, 8)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
