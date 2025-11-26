import SwiftUI

struct FilterChip: View {
  let title: String
  let isActive: Bool
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isActive ? .blue : Color(.systemGray5))
        .foregroundStyle(isActive ? .white : .primary)
        .cornerRadius(20)
    }
  }
}

#Preview {
  FilterChip(title: "Title", isActive: false, action: {})
}
