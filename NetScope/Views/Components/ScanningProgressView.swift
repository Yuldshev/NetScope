import SwiftUI
import Lottie

struct ScanningProgressView: View {
  let progress: Double

  var body: some View {
    VStack(spacing: 12) {
      LottieView(animation: .named("radar"))
        .playing(loopMode: .loop)
        .animationSpeed(1.0)
        .frame(width: 200, height: 200)
      
      Text("Идет сканирование: \(progress * 100, specifier: "%.0f")%")
        .font(.title3)
      
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

#Preview {
  ZStack {
    ScanningProgressView(progress: 0.1)
  }
}
