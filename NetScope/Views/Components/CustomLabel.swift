import SwiftUI

struct CustomLabel: View {
  let title: String
  let icon: String
  var font: Font? = .caption
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: icon)
      Text(title)
        .font(font)
    }
  }
}

// MARK: - Preview
#Preview {
  CustomLabel(title: "Example", icon: "globe")
}
