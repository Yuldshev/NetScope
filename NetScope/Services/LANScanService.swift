import Foundation

final class LANScanService: NSObject, ScanServiceProtocol {
  private let networkInfoProvider = NetworkInfoProvider()
  private let rangeGenerator = IPRangeGenerator()
  private let portScanner = TCPPortScanner()
  private let arpReader = ARPTableReader()
  private let hostnameResolver = HostnameResolver()
  
  private var discoveredDevices = [String: LANDeviceModel]()
  private var continuation: CheckedContinuation<[DeviceModel], Error>?
  private var scanTask: Task<Void, Never>?
  private var isScanningActive = false
  
  private let commonPorts = [80, 443, 22, 445, 8080]
  private let portScanTimeout: TimeInterval = 0.8
    
  func startScan(timeout: TimeInterval) async throws -> [DeviceModel] {
    guard !isScanningActive else {
      throw ScanError.scanAlreadyInProgress
    }
    
    return try await withCheckedThrowingContinuation { continuation in
      self.continuation = continuation
      self.discoveredDevices.removeAll()
      self.isScanningActive = true
      
      scanTask = Task {
        try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
        if !Task.isCancelled {
          await self.finishScan(withTimeout: true)
        }
      }
      
      Task {
        await self.performScan()
      }
    }
  }
  
  func stopScan() {
    scanTask?.cancel()
    scanTask = nil
    isScanningActive = false
  }
}

// MARK: - Helper
private extension LANScanService {
  private func performScan() async {
    do {
      let networkInfo = try networkInfoProvider.getCurrentNetworkInfo()
      
      let ranges = rangeGenerator.generateSmartRanges(
        baseIP: networkInfo.localIP,
        subnetMask: networkInfo.subnetMask
      )
      
      for range in ranges {
        guard isScanningActive else { break }
        
        let results = await portScanner.scanMultipleHosts(
          ips: range.ipAddresses,
          ports: commonPorts,
          timeout: portScanTimeout
        )
        
        await processResults(results)
      }
      
      await finishScan(withTimeout: false)
      
    } catch {
      stopScan()
      continuation?.resume(throwing: error)
      continuation = nil
    }
  }
  
  private func processResults(_ results: [ScanResult]) async {
    try? await Task.sleep(nanoseconds: 500_000_000)
    
    let arpEntries = (try? arpReader.readARPTable()) ?? []
    let arpMap = Dictionary(uniqueKeysWithValues: arpEntries.map { ($0.ipAddress, $0.macAddress) })
    
    let ips = results.map { $0.ipAddress }
    let hostnameMap = await hostnameResolver.resolveMultiple(
      ips: ips,
      timeout: 2.0
    )
    
    for result in results {
      let ip = result.ipAddress
      let macAddress = arpMap[ip]
      let hostname = hostnameMap[ip]
      
      let device = LANDeviceModel(
        id: UUID(),
        name: hostname ?? ip,
        discoveredAt: Date(),
        ipAddress: ip,
        macAddress: macAddress,
        hostName: hostname
      )
      discoveredDevices[ip] = device
    }
  }
  
  private func finishScan(withTimeout: Bool) async {
    stopScan()
    
    let devices = discoveredDevices.values.map { DeviceModel.lan($0) }
    
    if withTimeout && devices.isEmpty {
      continuation?.resume(throwing: ScanError.scanTimeout)
    } else {
      continuation?.resume(returning: Array(devices))
    }
    
    continuation = nil
  }
}
