import SwiftUI

struct MapDraggableSheetView: View {
    @ObservedObject var viewModel: EventsMapViewModel
    @Binding var sheetHeight: CGFloat
    let dragOffset: CGFloat
    @GestureState var updatingGesture: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Spacer()
                    Capsule().fill(Color.secondary.opacity(0.3)).frame(width: 40, height: 5)
                    Spacer()
                }.padding(.top, 12)
                
                HStack {
                    Text("Explore locais perto de você").font(.title3).fontWeight(.semibold)
                    Spacer()
                    if viewModel.isLoading { ProgressView() }
                }.padding(.horizontal, 16)
            }
            .padding(.bottom, 12).contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($updatingGesture) { value, state, _ in state = value.translation.height }
                    .onEnded { value in
                        let dragAmount = value.translation.height
                        let targetHeight = sheetHeight - dragAmount
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            if targetHeight > UIScreen.main.bounds.height * 0.65 {
                                sheetHeight = UIScreen.main.bounds.height - 150
                            } else if targetHeight > 250 {
                                sheetHeight = 400
                            } else {
                                sheetHeight = 200
                            }
                        }
                    }
            )
            
            EventListSheetView(events: viewModel.nearbyEvents, isLoading: viewModel.isLoading)
        }
        .frame(height: max(200, sheetHeight - dragOffset))
        .background(.regularMaterial)
        .clipShape(CustomSheetCorners(radius: 24, corners: [.topLeft, .topRight]))
        .shadow(color: .black.opacity(0.15), radius: 8, y: -4)
    }
}
