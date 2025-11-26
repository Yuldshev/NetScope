import SwiftUI

struct DeviceRowView: View {
  let device: DeviceModel
  
  var body: some View {
    HStack(spacing: 12) {
      deviceIcon
      
      VStack(alignment: .leading, spacing: 4) {
        Text(device.name ?? "Неизвестное устройство")
          .font(.headline)
          .lineLimit(1)
        
        deviceDetails
      }
      
      Spacer()
      
      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 8)
  }
  
  // MARK: - Device Icon
  private var deviceIcon: some View {
    ZStack {
      Circle()
        .fill(iconBackgroundColor)
        .frame(width: 44, height: 44)
      
      Image(systemName: iconName)
        .foregroundColor(iconColor)
        .font(.system(size: 20))
    }
  }
  
  // MARK: - Device Details
  @ViewBuilder
  private var deviceDetails: some View {
    switch device {
      case .bluetooth(let btDevice):
        HStack(spacing: 12) {
          HStack(spacing: 4) {
            Image(systemName: "antenna.radiowaves.left.and.right")
            Text("Bluetooth")
              .font(.caption)
          }
          .foregroundStyle(.blue)
          
          Text("\(btDevice.rssi) dBm")
            .font(.caption)
            .foregroundColor(.secondary)
        }
        
      case .lan(let lanDevice):
        HStack(spacing: 12) {
          HStack(spacing: 4) {
            Image(systemName: "network")
            Text("LAN")
              .font(.caption)
          }
          .foregroundColor(.green)
          
          Text(lanDevice.ipAddress)
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
  }
  
  // MARK: - Computed Properties
  private var iconName: String {
    switch device.deviceType {
      case .bluetooth: return "antenna.radiowaves.left.and.right"
      case .lan: return "network"
    }
  }
  
  private var iconColor: Color {
    switch device.deviceType {
      case .bluetooth: return .blue
      case .lan: return .green
    }
  }
  
  private var iconBackgroundColor: Color {
    switch device.deviceType {
      case .bluetooth: return Color.blue.opacity(0.1)
      case .lan: return Color.green.opacity(0.1)
    }
  }
}


#Preview {
  List {
    DeviceRowView(
      device: .bluetooth(
        BluetoothDeviceModel(
          name: "iPhone 12",
          uuid: "12345",
          rssi: -45,
          connectionStatus: .connected
        )
      )
    )
    
    DeviceRowView(
      device: .lan(
        LANDeviceModel(
          name: "MacBook Pro",
          ipAddress: "192.168.1.5",
          macAddress: "AA:BB:CC:DD:EE:FF",
          hostName: "MacBook-Pro.local"
        )
      )
    )
  }
}
