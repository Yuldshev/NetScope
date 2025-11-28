import SwiftUI

struct DeviceDetailView: View {
  let device: DeviceModel
  
  var body: some View {
    List {
      Section {
        InfoSectionView(title: "Тип") { deviceTypeLabel }
        InfoSectionView(title: "Имя") { Text(device.name ?? "Неизвестно") }
        InfoSectionView(title: "Обнаружено") { Text(formatDate(device.discoveredAt)) }
      } header: {
        Text("Общая информация")
      }
      
      switch device {
      case .bluetooth(let btDevice):
        bluetoothDetailsSection(btDevice)
        
      case .lan(let lanDevice):
        lanDetailsSection(lanDevice)
      }
    }
    .navigationTitle("Детали устройства")
    .navigationBarTitleDisplayMode(.inline)
  }
  
  // MARK: - Bluetooth Details
  private func bluetoothDetailsSection(_ device: BluetoothDeviceModel) -> some View {
    Section {
      InfoSectionView(title: "UUID") { Text(device.uuid) }
      InfoSectionView(title: "Уровень сигнала") { signalStrengthView(rssi: device.rssi) }
      InfoSectionView(title: "Статус подключения") { connectionStatusBadge(device.connectionStatus) }
    } header: {
      Text("Bluetooth детали")
    }
  }
  
  // MARK: - LAN Details
  private func lanDetailsSection(_ device: LANDeviceModel) -> some View {
    Section {
      InfoSectionView(title: "IP адрес") { Text(device.ipAddress) }
      
      if let mac = device.macAddress {
        InfoSectionView(title: "MAC адрес") { Text(mac) }
      }
      
      if let hostname = device.hostName {
        InfoSectionView(title: "Имя хоста") { Text(hostname) }
      }
    } header: {
      Text("LAN детали")
    }
  }
  
  private var deviceTypeLabel: some View {
    BadgeView(
      text: device.deviceType.name,
      icon: device.deviceType.icon,
      color: device.deviceType.color
    )
  }
  
  private func signalStrengthView(rssi: Int) -> some View {
    HStack(spacing: 4) {
      Text("\(rssi) dBm")
        .font(.callout)
      
      Image(systemName: signalIcon(for: rssi))
        .foregroundColor(signalColor(for: rssi))
    }
  }
  
  private func connectionStatusBadge(_ status: BluetoothConnectionStatus) -> some View {
    BadgeView(text: status.displayName, color: statusColor(status))
  }
  
  // MARK: - Helper Functions
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter.string(from: date)
  }
  
  private func signalIcon(for rssi: Int) -> String {
    switch rssi {
    case -50...0:
      return "wifi.circle.fill"
    case -60 ..< -50:
      return "wifi.circle"
    case -70 ..< -60:
      return "wifi.slash"
    default:
      return "wifi.exclamationmark"
    }
  }
  
  private func signalColor(for rssi: Int) -> Color {
    switch rssi {
    case -50...0:
      return .green
    case -60 ..< -50:
      return .yellow
    case -70 ..< -60:
      return .orange
    default:
      return .red
    }
  }
  
  private func statusColor(_ status: BluetoothConnectionStatus) -> Color {
    switch status {
    case .connected:
      return .green
    case .connecting:
      return .blue
    case .disconnected:
      return .gray
    }
  }
}

// MARK: - Preview
#Preview {
  DeviceDetailView(device: .bluetooth(BluetoothDeviceModel(name: "", uuid: "", rssi: 1)))
}
