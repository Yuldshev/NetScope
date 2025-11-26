import SwiftUI

struct ScanView: View {
  @StateObject private var vm = ScanViewModel()
  @State private var selectedDevice: DeviceModel?
  @State private var showHistory = false
  @State private var showDeviceDetail = false
  
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
        .navigationTitle("NetScope")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            NavigationLink(isActive: $showHistory) {
              HistoryView()
            } label: {
              Label("История", systemImage: "clock.arrow.circlepath")
            }
          }
        }
        .background(
          NavigationLink(isActive: $showDeviceDetail) {
            if let device = selectedDevice {
              DeviceDetailView(device: device)
            }
          } label: {
            EmptyView()
          }
        )
        .alert(item: $vm.alertConfig) { config in
          Alert(title: Text(config.title), message: Text(config.message), dismissButton: .default(Text("OK")))
        }
      }
    }
  }
}

// MARK: - Helper
private extension ScanView {
  var statsSection: some View {
    VStack(spacing: 12) {
      HStack(spacing: 16) {
        StatCard(title: "Bluetooth", count: vm.bluetoothDeviceCount, color: .blue)
        StatCard(title: "LAN", count: vm.lanDeviceCount, color: .green)
        StatCard(title: "Всего", count: vm.totalDeviceCount, color: .purple)
      }
      .padding(.horizontal)
      
      HStack(spacing: 12) {
        if vm.isScanning {
          Button { vm.stopScan() } label: {
            Label("Остановить", systemImage: "stop.circle.fill")
              .frame(maxWidth: .infinity)
              .padding()
              .background(.red)
              .foregroundStyle(.white)
              .cornerRadius(12)
          }
        } else {
          Button { vm.startScan() } label: {
            Label("Начать сканирование", systemImage: "antenna.radiowaves.left.and.right")
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
                .background(.gray.opacity(0.2))
                .foregroundStyle(.red)
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
        emptyState
      } else {
        List {
          ForEach(vm.discoveredDevices) { device in
            Button {
              selectedDevice = device
              showDeviceDetail = true
            } label: {
              DeviceRowView(device: device)
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
  }
  
  var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: "network.slash")
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
        .foregroundStyle(.gray)
      
      Text("Устройства не найдены")
        .font(.headline)
        .foregroundStyle(.gray)
      
      Text("Нажмите кнопку сканирования для поиска устройств")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

// MARK: - Preview
#Preview {
  ScanView()
}
