import SwiftUI

struct EventDetailHeaderImage: View {
    let imageUrl: String?
    var body: some View {
        AsyncImage(url: URL(string: imageUrl ?? "")) { phase in
            if let image = phase.image {
                image.resizable().renderingMode(.original).scaledToFill()
            } else {
                Color(uiColor: .systemGray5)
                    .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: 320)
        .clipped()
    }
}

struct EventDetailTitleSection: View {
    let title: String
    let description: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            if let desc = description, !desc.isEmpty {
                Text(desc)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)
            }
        }
    }
}

struct EventRulesSection: View {
    let requiresDocument: Bool
    let isAgeRestricted: Bool
    var body: some View {
        SectionView(title: "Regulamento") {
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(icon: "person.text.rectangle", text: requiresDocument ? "Obrigatório apresentar documento oficial com foto." : "Não é exigida apresentação de documento.")
                InfoRow(icon: "18.circle", text: isAgeRestricted ? "Válido apenas para maiores de 18 anos." : "Livre para todas as idades.")
            }
        }
    }
}

struct EventTicketsSection: View {
    @ObservedObject var viewModel: EventDetailViewModel
    var body: some View {
        SectionView(title: "Ingressos") {
            if viewModel.isLoadingTickets {
                HStack { Spacer(); ProgressView("Buscando ingressos..."); Spacer() }.padding(.vertical)
            } else if viewModel.ticketTypes.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "lock.fill").foregroundColor(.orange)
                    Text("Ingressos ainda não liberados").fontWeight(.semibold).foregroundColor(.orange)
                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 12) {
                    ForEach(viewModel.ticketTypes) { ticket in
                        TicketCardView(ticket: ticket, isSelected: viewModel.selectedTicket?.id == ticket.id) {
                            viewModel.selectTicket(ticket)
                        }
                    }
                }
            }
        }
    }
}

struct EventDetailBottomBar: View {
    let isTicketSelected: Bool
    let onMapTap: () -> Void
    let onCheckoutTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 16) {
                Button(action: onMapTap) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.title3).foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                Button(action: onCheckoutTap) {
                    HStack {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Garantir Ingresso").fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 56)
                    .background(isTicketSelected ? Color.accentColor : Color.gray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(!isTicketSelected)
            }
            .padding(.horizontal, 24).padding(.top, 16).padding(.bottom, 20)
        }
        .background(Color(.systemBackground).shadow(color: .black.opacity(0.05), radius: 10, y: -5).ignoresSafeArea(edges: .bottom))
    }
}

struct BackButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                .frame(width: 44, height: 44).background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
        .padding(.leading, 20).padding(.top, 10)
    }
}
