import Foundation
@testable import NetScope

final class MockScanService: ScanServiceProtocol {
  var shouldThrowError: Error?
  var devicesToReturn: [DeviceModel] = []
  var scanCalled = false
  var stopCalled = false
  var scanDuration: TimeInterval = 0.2
  
  func startScan(timeout: TimeInterval) async throws -> [DeviceModel] {
    scanCalled = true
    
    if let error = shouldThrowError {
      throw error
    }
    
    try await Task.sleep(nanoseconds: UInt64(scanDuration * 1_000_000_000))
    
    return devicesToReturn
  }
  
  func stopScan() {
    stopCalled = true
  }
}
