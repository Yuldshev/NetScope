import Foundation

struct ScanSessionModel: Identifiable, Hashable {
  let id: UUID
  let timestamp: Date
  let devicesFound: Int
  let devices: [DeviceModel]
  
  init(
    id: UUID = UUID(),
    timestamp: Date = Date(),
    devicesFound: Int = 0,
    devices: [DeviceModel] = []
  ) {
    self.id = id
    self.timestamp = timestamp
    self.devicesFound = devicesFound
    self.devices = devices
  }
  
  var bluetoothDeviceCount: Int {
    devices.filter { $0.deviceType == .bluetooth }.count
  }
  
  var lanDeviceCount: Int {
    devices.filter { $0.deviceType == .lan }.count
  }
  
  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter.string(from: timestamp)
  }
}
