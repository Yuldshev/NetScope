import Foundation

final class ScanOrchestrator {
  private let bluetoothService: ScanServiceProtocol
  private let lanService: ScanServiceProtocol
  private let repository: ScanRepositoryProtocol
  
  init(
    bluetoothService: ScanServiceProtocol = BluetoothScanService(),
    lanService: ScanServiceProtocol = LANScanService(),
    repository: ScanRepositoryProtocol = ScanRepository()
  ) {
    self.bluetoothService = bluetoothService
    self.lanService = lanService
    self.repository = repository
  }
  
  func performFullScan() async throws -> ScanSessionModel {
    async let btDevices = bluetoothService.startScan(timeout: 15)
    async let lanDevices = lanService.startScan(timeout: 15)
    
    do {
      let btResult = try await btDevices
      let lanResult = try await lanDevices
      let allDevices = btResult + lanResult
      
      let session = ScanSessionModel(
        timestamp: Date(),
        devicesFound: allDevices.count,
        devices: allDevices
      )
      
      let savedSession = try await repository.saveScanSession(session)
      return savedSession
      
    } catch {
      stopAllScans()
      throw error
    }
  }
  
  func stopAllScans() {
    bluetoothService.stopScan()
    lanService.stopScan()
  }
}
