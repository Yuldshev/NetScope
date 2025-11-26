import Foundation
import CoreData

extension CDLANDevice {
  func toModel() -> LANDeviceModel {
    return LANDeviceModel(
      id: self.id ?? UUID(),
      name: self.name,
      discoveredAt: self.discoveredAt ?? Date(),
      ipAddress: self.ipAddress ?? "",
      macAddress: self.macAddress,
      hostName: self.hostName
    )
  }
}
