import SwiftUI

struct MapRadiusFilterView: View {
    let radiusOptions: [Double]
    let currentRadius: Double
    let onSelect: (Double) -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(radiusOptions, id: \.self) { radius in
                        Button(action: { onSelect(radius) }) {
                            Text("\(Int(radius / 1000)) km")
                                .fontWeight(.semibold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(currentRadius == radius ? Color.accentColor : Color(.systemBackground))
                                .foregroundColor(currentRadius == radius ? .white : .primary)
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        }
                    }
                }
                .padding(.horizontal).padding(.top, 60)
            }
        }
    }
}
