import SwiftUI

struct EmptyStateView: View {
  let icon: String
  let title: String
  let subtitle: String
  let action: (() -> Void)?
  let actionTitle: String?
  
  init(
    icon: String,
    title: String,
    subtitle: String,
    actionTitle: String? = nil,
    action: (() -> Void)? = nil
  ) {
    self.icon = icon
    self.title = title
    self.subtitle = subtitle
    self.actionTitle = actionTitle
    self.action = action
  }
  
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: icon)
        .font(.system(size: 60))
        .foregroundColor(.secondary)
      
      Text(title)
        .font(.headline)
      
      Text(subtitle)
        .font(.subheadline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      
      if let action, let actionTitle {
        Button(actionTitle, action: action)
          .buttonStyle(.bordered)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  EmptyStateView(icon: "globe", title: "Example", subtitle: "Preview text example")
}
