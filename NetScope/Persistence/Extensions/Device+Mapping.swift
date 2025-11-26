import Foundation
import CoreData

extension CDDevice {
  func toModel() -> DeviceModel? {
    if let btDevice = self as? CDBluetoothDevice {
      return .bluetooth(btDevice.toModel())
    } else if let lanDevice = self as? CDLANDevice {
      return .lan(lanDevice.toModel())
    }
    return nil
  }
}
