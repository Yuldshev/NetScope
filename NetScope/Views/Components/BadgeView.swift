import SwiftUI

struct BadgeView: View {
  let text: String
  var icon: String? = nil
  let color: Color
  
  var body: some View {
    HStack(spacing: 6) {
      if let icon {
        Image(systemName: icon)
          .font(.caption)
      }
      Text(text)
        .font(.caption)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(color.opacity(0.1))
    .foregroundStyle(color)
    .cornerRadius(8)
  }
}

#Preview {
  BadgeView(text: "Bluetooth", color: .blue)
}
