import SwiftUI

struct ScanView: View {
  @StateObject private var vm = ScanViewModel()
  @State private var showHistory = false
  
  var body: some View {
    NavigationView {
      ZStack {
        VStack(spacing: 0) {
          statsSection
          deviceListSection
          
          if vm.isScanning {
            ScanningProgressView(progress: vm.scanProgress)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing) {
          NavigationLink(isActive: $showHistory) {
            HistoryView()
          } label: {
            Image(systemName: "clock.arrow.circlepath")
              .foregroundStyle(.black)
              .padding()
              .background(.white)
              .clipShape(Circle())
              .padding()
          }
        }
        .alert(item: $vm.alertConfig) { config in
          Alert(title: Text(config.title), message: Text(config.message), dismissButton: .default(Text("OK")))
        }
      }
      .animation(.smooth, value: vm.isScanning)
    }
  }
}

// MARK: - Helper
private extension ScanView {
  var statsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("NetScope")
        .font(.system(size: 32, weight: .bold))
        .padding()
      
      HStack(spacing: 16) {
        StatCard(title: "Bluetooth", count: vm.bluetoothDeviceCount, color: .blue)
        StatCard(title: "LAN", count: vm.lanDeviceCount, color: .green)
        StatCard(title: "Всего", count: vm.totalDeviceCount, color: .purple)
      }
      .padding(.horizontal)
      
      HStack(spacing: 12) {
        if vm.isScanning {
          Button { vm.stopScan() } label: {
            CustomLabel(title: "Остановить", icon: "stop.circle.fill", font: .headline)
              .frame(maxWidth: .infinity)
              .padding()
              .background(.red)
              .foregroundStyle(.white)
              .cornerRadius(12)
          }
        } else {
          Button { vm.startScan() } label: {
            CustomLabel(title: "Начать сканирование", icon: "antenna.radiowaves.left.and.right", font: .headline)
              .frame(maxWidth: .infinity)
              .padding()
              .background(.blue)
              .foregroundStyle(.white)
              .cornerRadius(12)
          }
          
          if !vm.discoveredDevices.isEmpty {
            Button { vm.clearDevices() } label: {
              Image(systemName: "trash")
                .padding()
                .background(.red)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
          }
        }
      }
      .padding(.horizontal)
    }
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
  }
  
  var deviceListSection: some View {
    ZStack {
      if vm.discoveredDevices.isEmpty {
        if !vm.isScanning { emptyState }
      } else {
        List {
          ForEach(vm.discoveredDevices) { device in
            NavigationLink(destination: DeviceDetailView(device: device)) {
              DeviceRowView(device: device)
            }
          }
        }
        .transition(.opacity)
      }
    }
  }
  
  var emptyState: some View {
    EmptyStateView(
      icon: "network.slash",
      title: "Устройства не найдены",
      subtitle: "Нажмите кнопку сканирования для поиска устройств"
    )
    .overlay(alignment: .bottom) {
      Text("Created by: @yuldshev")
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .transition(.opacity)
  }
}

// MARK: - Preview
#Preview("Empty") {
  NavigationView {
    ScanView()
  }
}
