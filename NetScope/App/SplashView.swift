import SwiftUI
import Lottie

struct SplashView: View {
  var body: some View {
    ZStack {
      LottieView(animation: .named("scanner"))
        .playing(loopMode: .loop)
        .animationSpeed(1.0)
        .scaleEffect(4.5)
    }
    .ignoresSafeArea()
  }
}

#Preview {
  SplashView()
}
