import XCTest
@testable import NetScope

@MainActor
final class ScanViewModelTests: XCTestCase {
  var viewModel: ScanViewModel!
  var mockOrchestrator: ScanOrchestrator!
  var mockBTService: MockScanService!
  var mockLANService: MockScanService!
  var mockRepository: MockScanRepository!
  
  override func setUp() async throws {
    try await super.setUp()
    mockBTService = MockScanService()
    mockLANService = MockScanService()
    mockRepository = MockScanRepository()
    mockOrchestrator = ScanOrchestrator(
      bluetoothService: mockBTService,
      lanService: mockLANService,
      repository: mockRepository
    )
    viewModel = ScanViewModel(scanOrchestrator: mockOrchestrator)
  }
  
  override func tearDown() async throws {
    viewModel = nil
    mockOrchestrator = nil
    mockBTService = nil
    mockLANService = nil
    mockRepository = nil
    try await super.tearDown()
  }
  
  // MARK: - Переходы состояний
  func testStartScan_Success_UpdatesStateCorrectly() async throws {
    let btDevices = [DeviceModel.mockBluetooth(name: "BT1")]
    let lanDevices = [DeviceModel.mockLAN(name: "LAN1", ip: "192.168.1.100")]
    
    mockBTService.devicesToReturn = btDevices
    mockLANService.devicesToReturn = lanDevices
    
    XCTAssertEqual(viewModel.scanState, .idle, "Initial state should be idle")
    
    viewModel.startScan()
    
    try await Task.sleep(nanoseconds: 10_000_000)
    XCTAssertEqual(viewModel.scanState, .scanning, "State should be scanning after start")
    
    try await Task.sleep(nanoseconds: 250_000_000)
    
    XCTAssertEqual(viewModel.scanState, .success, "State should be success after scan completes")
    
    try await Task.sleep(nanoseconds: 600_000_000)
    XCTAssertEqual(viewModel.scanState, .idle, "State should transition to idle after success")
  }
  
  // MARK: - Обновление списка устройств после успешного сканирования
  func testStartScan_Success_UpdatesDiscoveredDevices() async throws {
    let btDevices = [DeviceModel.mockBluetooth(name: "BT1"), DeviceModel.mockBluetooth(name: "BT2")]
    let lanDevices = [DeviceModel.mockLAN(name: "LAN1", ip: "192.168.1.100")]
    
    mockBTService.devicesToReturn = btDevices
    mockLANService.devicesToReturn = lanDevices
    
    XCTAssertEqual(viewModel.discoveredDevices.count, 0, "Initially should have no devices")
    
    viewModel.startScan()
    
    try await Task.sleep(nanoseconds: 300_000_000)
    
    XCTAssertEqual(viewModel.discoveredDevices.count, 3, "Should have 3 discovered devices")
    XCTAssertEqual(viewModel.totalDeviceCount, 3, "Total device count should be 3")
  }
  
  // MARK: - Корректный подсчет устройств по типам
  func testDeviceCounts_ReturnsCorrectValues() async throws {
    let btDevices = [DeviceModel.mockBluetooth(name: "BT1"), DeviceModel.mockBluetooth(name: "BT2")]
    let lanDevices = [DeviceModel.mockLAN(name: "LAN1", ip: "192.168.1.100")]
    
    mockBTService.devicesToReturn = btDevices
    mockLANService.devicesToReturn = lanDevices
    viewModel.startScan()
    
    try await Task.sleep(nanoseconds: 300_000_000)
    
    XCTAssertEqual(viewModel.bluetoothDeviceCount, 2, "Should have 2 Bluetooth devices")
    XCTAssertEqual(viewModel.lanDeviceCount, 1, "Should have 1 LAN device")
    XCTAssertEqual(viewModel.totalDeviceCount, 3, "Should have 3 total devices")
  }
  
  // MARK: - Обработка ошибок сканирования
  func testStartScan_Error_UpdatesStateToError() async throws {
    mockBTService.shouldThrowError = ScanError.bluetoothPoweredOff
    
    XCTAssertEqual(viewModel.scanState, .idle, "Initial state should be idle")
    
    viewModel.startScan()
    
    try await Task.sleep(nanoseconds: 200_000_000)
    
    if case .error(let error) = viewModel.scanState {
      if case .bluetoothPoweredOff = error {
      } else {
        XCTFail("Should be Bluetooth powered off error, got: \(error)")
      }
    } else {
      XCTFail("State should be error")
    }
    
    XCTAssertNotNil(viewModel.alertConfig, "Alert should be shown for error")
    
    try await Task.sleep(nanoseconds: 1_100_000_000)
    XCTAssertEqual(viewModel.scanState, .idle, "State should transition back to idle after error")
  }
  
  // MARK: - Остановка сканирования вручную
  func testStopScan_WhileScanning_StopsAndResetsState() async throws {
    mockBTService.devicesToReturn = [DeviceModel.mockBluetooth()]
    mockLANService.devicesToReturn = [DeviceModel.mockLAN()]
    
    viewModel.startScan()
    
    try await Task.sleep(nanoseconds: 10_000_000)
    
    XCTAssertEqual(viewModel.scanState, .scanning, "State should be scanning")
    
    viewModel.stopScan()
    
    XCTAssertEqual(viewModel.scanState, .idle, "State should be idle after stop")
    XCTAssertEqual(viewModel.scanProgress, 0.0, "Progress should be reset to 0")
    XCTAssertTrue(mockBTService.stopCalled, "Bluetooth service should be stopped")
    XCTAssertTrue(mockLANService.stopCalled, "LAN service should be stopped")
    XCTAssertNotNil(viewModel.alertConfig, "Alert should be shown when stopped")
  }
  
  // MARK: - isScanning computed property
  func testIsScanning_ReflectsScanState() async throws {
    mockBTService.devicesToReturn = [DeviceModel.mockBluetooth()]
    mockLANService.devicesToReturn = []
    
    XCTAssertFalse(viewModel.isScanning, "Initially should not be scanning")
    
    viewModel.startScan()
    
    try await Task.sleep(nanoseconds: 10_000_000)
    XCTAssertTrue(viewModel.isScanning, "Should be scanning right after start")
  }
  
  // MARK: - Prevent double scan
  func testStartScan_WhileAlreadyScanning_ShowsAlert() async throws {
    mockBTService.devicesToReturn = [DeviceModel.mockBluetooth()]
    mockLANService.devicesToReturn = []
    viewModel.startScan()
    
    try await Task.sleep(nanoseconds: 10_000_000)
    
    viewModel.alertConfig = nil
    viewModel.startScan()
    
    XCTAssertNotNil(viewModel.alertConfig, "Should show alert when trying to scan while already scanning")
    XCTAssertEqual(viewModel.alertConfig?.title, "Сканирование уже выполняется", "Alert should have correct title")
  }
}
