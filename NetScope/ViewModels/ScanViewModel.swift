import Foundation
import Combine

@MainActor
final class ScanViewModel: ObservableObject {
  @Published private(set) var scanState: ScanState = .idle
  @Published private(set) var discoveredDevices: [DeviceModel] = []
  @Published var alertConfig: AlertConfig?
  @Published private(set) var scanProgress: Double = 0.0
  
  // MARK: - Private Properties
  private let scanOrchestrator: ScanOrchestrator
  private var currentScanTask: Task<Void, Never>?
  private var progressTask: Task<Void, Never>?
  
  // MARK: - Computed Properties
  var isScanning: Bool {
    scanState == .scanning
  }
  
  var bluetoothDeviceCount: Int {
    discoveredDevices.filter { $0.deviceType == .bluetooth }.count
  }
  
  var lanDeviceCount: Int {
    discoveredDevices.filter { $0.deviceType == .lan }.count
  }
  
  var totalDeviceCount: Int {
    discoveredDevices.count
  }
  
  init(scanOrchestrator: ScanOrchestrator) {
    self.scanOrchestrator = scanOrchestrator
  }
  
  convenience init() {
    self.init(scanOrchestrator: ScanOrchestrator())
  }
  
  // MARK: - Public Methods
  func startScan() {
    guard scanState != .scanning else {
      showAlert(
        title: "Сканирование уже выполняется",
        message: "Пожалуйста, дождитесь завершения текущего сканирования"
      )
      return
    }
    
    discoveredDevices.removeAll()
    scanProgress = 0.0
    scanState = .scanning
    startProgressTimer()
    
    currentScanTask = Task { [weak self] in
      await self?.performScan()
    }
  }
  
  func stopScan() {
    guard scanState == .scanning else { return }
    currentScanTask?.cancel()
    currentScanTask = nil
    scanOrchestrator.stopAllScans()
    stopProgressTimer()
    scanState = .idle
    scanProgress = 0.0
    showAlert(
      title: "Сканирование остановлено",
      message: "Обнаружено устройств: \(totalDeviceCount)"
    )
  }
  
  func clearDevices() {
    discoveredDevices.removeAll()
  }
  
  // MARK: - Private Methods
  private func performScan() async {
    do {
      let session = try await scanOrchestrator.performFullScan()
      
      guard !Task.isCancelled else {
        handleScanCancellation()
        return
      }
      handleScanSuccess(session: session)
    } catch let error as ScanError {
      handleScanError(error)
    } catch {
      handleScanError(.scanFailed(error.localizedDescription))
    }
  }
  
  private func handleScanSuccess(session: ScanSessionModel) {
    stopProgressTimer()
    scanProgress = 1.0
    discoveredDevices = session.devices
    scanState = .success
    showAlert(
      title: "Сканирование завершено",
      message: """
               Обнаружено устройств: \(session.devicesFound)
               Bluetooth: \(session.bluetoothDeviceCount)
               LAN: \(session.lanDeviceCount)
               """
    )
    
    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 500_000_000)
      if scanState == .success {
        scanState = .idle
      }
    }
  }
  
  private func handleScanError(_ error: ScanError) {
    stopProgressTimer()
    scanProgress = 0.0
    scanState = .error(error)
    showAlert(
      title: "Ошибка сканирования",
      message: error.localizedDescription
    )
    
    Task { @MainActor in
      try? await Task.sleep(nanoseconds: 1_000_000_000)
      if case .error = scanState {
        scanState = .idle
      }
    }
  }
  
  private func handleScanCancellation() {
    stopProgressTimer()
    scanProgress = 0.0
    scanState = .idle
  }
  
  private func startProgressTimer() {
    scanProgress = 0
    progressTask = Task { [weak self] in
      for _ in 0..<150 {
        guard !Task.isCancelled else { return }
        try? await Task.sleep(nanoseconds: 100_000_000)
        await MainActor.run {
          if let self = self, self.scanProgress < 0.95 {
            self.scanProgress += 0.00633
          }
        }
      }
    }
  }
  
  private func stopProgressTimer() {
    progressTask?.cancel()
    progressTask = nil
  }
  
  private func showAlert(title: String, message: String) {
    alertConfig = AlertConfig(
      title: title,
      message: message
    )
  }
  
  // MARK: - Cleanup
  deinit {
    currentScanTask?.cancel()
    progressTask?.cancel()
  }
}

// MARK: - Supporting types
enum ScanState: Equatable {
  case idle, scanning, success, error(ScanError)
  
  static func == (lhs: ScanState, rhs: ScanState) -> Bool {
    switch (lhs, rhs) {
      case (.idle, .idle): return true
      case (.scanning, .scanning): return true
      case (.success, .success): return true
      case (.error, .error): return true
      default: return false
    }
  }
}

// MARK: - Alert
struct AlertConfig: Identifiable {
  let id = UUID()
  let title: String
  let message: String
}
