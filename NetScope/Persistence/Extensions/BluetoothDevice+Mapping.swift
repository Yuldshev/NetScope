import Foundation
import CoreData

extension CDBluetoothDevice {
  func toModel() -> BluetoothDeviceModel {
    return BluetoothDeviceModel(
      id: self.id ?? UUID(),
      name: self.name,
      discoveredAt: self.discoveredAt ?? Date(),
      uuid: self.uuid ?? "",
      rssi: Int(self.rssi),
      connectionStatus: BluetoothConnectionStatus(rawValue: self.connectionStatus ?? "") ?? .disconnected
    )
  }
}
