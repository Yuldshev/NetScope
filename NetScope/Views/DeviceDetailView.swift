import SwiftUI

struct DeviceDetailView: View {
  let device: DeviceModel
  
  var body: some View {
    List {
      Section {
        HStack {
          Text("Тип")
          Spacer()
          deviceTypeLabel
        }
        labeledRow(label: "Имя", value: device.name ?? "Неизвестно")
        labeledRow(label: "Обнаружено", value: formatDate(device.discoveredAt))
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
      labeledRow(label: "UUID", value: device.uuid)
      
      HStack {
        Text("Уровень сигнала")
        Spacer()
        signalStrengthView(rssi: device.rssi)
      }
      
      HStack {
        Text("Статус подключения")
        Spacer()
        connectionStatusBadge(device.connectionStatus)
      }
    } header: {
      Text("Bluetooth детали")
    }
  }
  
  // MARK: - LAN Details
  private func lanDetailsSection(_ device: LANDeviceModel) -> some View {
    Section {
      labeledRow(label: "IP адрес", value: device.ipAddress)
      
      if let mac = device.macAddress {
        labeledRow(label: "MAC адрес", value: mac)
      }
      
      if let hostname = device.hostName {
        labeledRow(label: "Имя хоста", value: hostname)
      }
    } header: {
      Text("LAN детали")
    }
  }
  
  // MARK: - Helper Views
  private func labeledRow(label: String, value: String) -> some View {
    HStack {
      Text(label)
      Spacer()
      Text(value)
        .foregroundColor(.secondary)
    }
  }
  
  private var deviceTypeLabel: some View {
    HStack {
      Image(systemName: device.deviceType == .bluetooth ? "antenna.radiowaves.left.and.right" : "network")
      Text(device.deviceType == .bluetooth ? "Bluetooth" : "LAN")
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 6)
    .background(device.deviceType == .bluetooth ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
    .foregroundColor(device.deviceType == .bluetooth ? .blue : .green)
    .cornerRadius(8)
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
    Text(status.displayName)
      .font(.caption)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(statusColor(status).opacity(0.1))
      .foregroundColor(statusColor(status))
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
