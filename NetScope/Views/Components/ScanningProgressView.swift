import SwiftUI

struct ScanningProgressView: View {
  let progress: Double
  
  var body: some View {
    ZStack {
      Color.black.opacity(0.4)
        .ignoresSafeArea()
      
      VStack(spacing: 20) {
        ZStack {
          Circle()
            .stroke(Color.blue.opacity(0.2), lineWidth: 4)
            .frame(width: 80, height: 80)
          
          Circle()
            .trim(from: 0, to: progress)
            .stroke(
              Color.blue,
              style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 80, height: 80)
            .rotationEffect(.degrees(-90))
            .animation(.linear, value: progress)
          
          Image(systemName: "antenna.radiowaves.left.and.right")
            .font(.system(size: 32))
            .foregroundColor(.blue)
        }
        
        VStack(spacing: 8) {
          Text("Сканирование...")
            .font(.headline)
          
          Text("\(Int(progress * 100))%")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(.blue)
          
          Text("Поиск устройств в сети")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
        ProgressView(value: progress)
          .progressViewStyle(.linear)
          .tint(.blue)
          .padding(.horizontal, 32)
      }
      .padding(32)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(Color(.systemBackground))
          .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
      )
      .padding(.horizontal, 40)
    }
  }
}

#Preview {
  ZStack {
    Color.gray.ignoresSafeArea()
    ScanningProgressView(progress: 1)
  }
}

