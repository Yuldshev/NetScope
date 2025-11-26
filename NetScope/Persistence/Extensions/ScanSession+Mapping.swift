import Foundation
import CoreData

extension CDScanSession {
  func toModel() -> ScanSessionModel {
    let deviceModels = (self.devices as? Set<CDDevice>)?
      .compactMap { $0.toModel() }
      .sorted { $0.discoveredAt < $1.discoveredAt } ?? []
    
    return ScanSessionModel(
      id: self.id ?? UUID(),
      timestamp: self.timestamp ?? Date(),
      devicesFound: Int(self.devicesFound),
      devices: deviceModels
    )
  }
}
