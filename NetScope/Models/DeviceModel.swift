import SwiftUI

// MARK: - Base protocol
protocol DeviceProtocol {
  var id: UUID { get }
  var name: String? { get }
  var deviceType: DeviceType { get }
  var discoveredAt: Date { get }
}

// MARK: - Device type
enum DeviceType: String, CaseIterable {
  case bluetooth, lan
  
  var name: String {
    switch self {
    case .bluetooth: return "Bluetooth"
    case .lan: return "LAN"
    }
  }
  
  var icon: String {
    switch self {
    case .bluetooth: return "antenna.radiowaves.left.and.right"
    case .lan: return "network"
    }
  }
  
  var color: Color {
    switch self {
    case .bluetooth: return .blue
    case .lan: return .green
    }
  }
  
  var bg: Color {
    color.opacity(0.1)
  }
}

// MARK: - Bluetooth device
enum BluetoothConnectionStatus: String, CaseIterable {
  case disconnected, connecting, connected
  
  var displayName: String {
    switch self {
    case .disconnected: return "Disconnected"
    case .connecting: return "Connecting"
    case .connected: return "Connected"
    }
  }
}

// MARK: - Bluetooth device model
struct BluetoothDeviceModel: DeviceProtocol, Identifiable, Hashable {
  let id: UUID
  let name: String?
  let deviceType: DeviceType = .bluetooth
  let discoveredAt: Date
  let uuid: String
  let rssi: Int
  let connectionStatus: BluetoothConnectionStatus
  
  init(
    id: UUID = UUID(),
    name: String?,
    discoveredAt: Date = Date(),
    uuid: String,
    rssi: Int,
    connectionStatus: BluetoothConnectionStatus = .disconnected
  ) {
    self.id = id
    self.name = name
    self.discoveredAt = discoveredAt
    self.uuid = uuid
    self.rssi = rssi
    self.connectionStatus = connectionStatus
  }
}

// MARK: - Lan device model
struct LANDeviceModel: DeviceProtocol, Identifiable, Hashable {
  let id: UUID
  let name: String?
  let deviceType: DeviceType = .lan
  let discoveredAt: Date
  let ipAddress: String
  let macAddress: String?
  let hostName: String?
  
  init(
    id: UUID = UUID(),
    name: String?,
    discoveredAt: Date = Date(),
    ipAddress: String,
    macAddress: String?,
    hostName: String?
  ) {
    self.id = id
    self.name = name
    self.discoveredAt = discoveredAt
    self.ipAddress = ipAddress
    self.macAddress = macAddress
    self.hostName = hostName
  }
}

// MARK: - Device model for list
enum DeviceModel: Identifiable, Hashable {
  case bluetooth(BluetoothDeviceModel)
  case lan(LANDeviceModel)
  
  var id: UUID {
    switch self {
    case .bluetooth(let device): return device.id
    case .lan(let device): return device.id
    }
  }
  
  var name: String? {
    switch self {
    case .bluetooth(let device): return device.name
    case .lan(let device): return device.name
    }
  }
  
  var deviceType: DeviceType {
    switch self {
    case .bluetooth: return .bluetooth
    case .lan: return .lan
    }
  }
  
  var discoveredAt: Date {
    switch self {
    case .bluetooth(let device): return device.discoveredAt
    case .lan(let device): return device.discoveredAt
    }
  }
}
