import SwiftUI
import Combine

@MainActor
final class AppCoordinator: ObservableObject {
  @Published var showSplash = true
  
  init() { startSplashTimer() }
  
  private func startSplashTimer() {
    Task {
      try? await Task.sleep(nanoseconds: 2_000_000_000)
      withAnimation(.easeInOut(duration: 0.3)) {
        showSplash = false
      }
    }
  }
}
