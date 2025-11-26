import SwiftUI

struct StatCard: View {
  let title: String
  let count: Int
  let color: Color
  
  var body: some View {
    VStack(spacing: 8) {
      Text("\(count)")
        .font(.system(size: 28, weight: .bold, design: .rounded))
        .foregroundStyle(color)
      
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color(.systemBackground))
    .cornerRadius(12)
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}

#Preview {
  StatCard(title: "New Stats", count: 15, color: .red)
}
