import Foundation
import CoreBluetooth

final class BluetoothScanService: NSObject, ScanServiceProtocol {
  private var centralManager: CBCentralManager!
  private var discoveredDevices = [UUID: BluetoothDeviceModel]()
  private var continuation: CheckedContinuation<[DeviceModel], Error>?
  private var scanTask: Task<Void, Never>?
  private var isScanning = false
  
  override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: .global(qos: .userInitiated))
  }
  
  func startScan(timeout: TimeInterval) async throws -> [DeviceModel] {
    guard !isScanning else {
      throw ScanError.scanAlreadyInProgress
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      self.discoveredDevices.removeAll()
      self.isScanning = true
      
      guard centralManager.state == .poweredOn else {
        let error = getBluetoothError(for: centralManager.state)
        self.isScanning = false
        continuation.resume(throwing: error)
        return
      }
      
      scanTask = Task {
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        if !Task.isCancelled {
          self.finishScan(withTimeout: true)
        }
      }
      
      centralManager.scanForPeripherals(withServices: nil, options: [
        CBCentralManagerScanOptionAllowDuplicatesKey: false
      ])
    }
  }
  
  func stopScan() {
    scanTask?.cancel()
    scanTask = nil
    centralManager.stopScan()
    isScanning = false
  }
  
  private func finishScan(withTimeout: Bool = false) {
    stopScan()
    let devices = discoveredDevices.values.map { DeviceModel.bluetooth($0) }
    
    if withTimeout && devices.isEmpty {
      continuation?.resume(throwing: ScanError.scanTimeout)
    } else {
      continuation?.resume(returning: Array(devices))
    }
    continuation = nil
  }
  
  private func getBluetoothError(for state: CBManagerState) -> ScanError {
    switch state {
      case .unauthorized:
        return .bluetoothUnauthorized
      case .poweredOff:
        return .bluetoothPoweredOff
      case .unsupported, .unknown:
        return .bluetoothUnavailable
      default:
        return .bluetoothUnavailable
    }
  }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothScanService: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if isScanning && central.state != .poweredOn {
      let error = getBluetoothError(for: central.state)
      stopScan()
      continuation?.resume(throwing: error)
      continuation = nil
    }
  }
  
  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String : Any],
    rssi RSSI: NSNumber
  ) {
    let uuid = peripheral.identifier.uuidString
    let name = peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as?
    String
    let rssiValue = RSSI.intValue
    
    let connectionStatus: BluetoothConnectionStatus = {
      switch peripheral.state {
        case .connected: return .connected
        case .connecting: return .connecting
        default: return .disconnected
      }
    }()
    
    let device = BluetoothDeviceModel(
      id: peripheral.identifier,
      name: name,
      discoveredAt: Date(),
      uuid: uuid,
      rssi: rssiValue,
      connectionStatus: connectionStatus
    )
    
    discoveredDevices[peripheral.identifier] = device
  }
}
