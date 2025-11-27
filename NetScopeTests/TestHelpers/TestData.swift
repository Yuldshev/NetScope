import Foundation
@testable import NetScope

extension DeviceModel {
  static func mockBluetooth(
    name: String = "Test BT Device",
    uuid: String = "12345678-1234-1234-1234-123456789ABC",
    rssi: Int = -50
  ) -> DeviceModel {
    .bluetooth(BluetoothDeviceModel(
      name: name,
      uuid: uuid,
      rssi: rssi,
      connectionStatus: .disconnected
    ))
  }
  
  static func mockLAN(
    name: String? = "Test LAN Device",
    ip: String = "192.168.1.100",
    mac: String? = "AA:BB:CC:DD:EE:FF"
  ) -> DeviceModel {
    .lan(LANDeviceModel(
      name: name,
      ipAddress: ip,
      macAddress: mac,
      hostName: "device.local"
    ))
  }
}

extension ScanSessionModel {
  static func mock(devicesCount: Int = 5, bluetoothCount: Int = 2, lanCount: Int = 3) -> ScanSessionModel {
    var devices: [DeviceModel] = []
    
    for i in 0..<bluetoothCount {
      devices.append(.mockBluetooth(name: "BT Device \(i + 1)"))
    }
    
    for i in 0..<lanCount {
      devices.append(.mockLAN(name: "LAN Device \(i + 1)", ip: "192.168.1.\(100 + i)"))
    }
    
    return ScanSessionModel(
      timestamp: Date(),
      devicesFound: devices.count,
      devices: devices
    )
  }
  
  static func mockWithDate(date: Date, devicesCount: Int = 3) -> ScanSessionModel {
    let devices = (0..<devicesCount).map { _ in
      DeviceModel.mockBluetooth()
    }
    
    return ScanSessionModel(
      timestamp: date,
      devicesFound: devices.count,
      devices: devices
    )
  }
}
