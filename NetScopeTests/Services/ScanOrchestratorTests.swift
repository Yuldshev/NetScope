import XCTest
@testable import NetScope

final class ScanOrchestratorTests: XCTestCase {
  var mockBTService: MockScanService!
  var mockLANService: MockScanService!
  var mockRepository: MockScanRepository!
  var orchestrator: ScanOrchestrator!
  
  override func setUp() {
    super.setUp()
    mockBTService = MockScanService()
    mockLANService = MockScanService()
    mockRepository = MockScanRepository()
    orchestrator = ScanOrchestrator(
      bluetoothService: mockBTService,
      lanService: mockLANService,
      repository: mockRepository
    )
  }
  
  override func tearDown() {
    mockBTService = nil
    mockLANService = nil
    mockRepository = nil
    orchestrator = nil
    super.tearDown()
  }
  
  // MARK: - BT + LAN сканирование
  @MainActor
  func testPerformFullScan_Success_ReturnsCombinedResults() async throws {
    let btDevices = [DeviceModel.mockBluetooth(name: "BT1"), DeviceModel.mockBluetooth(name: "BT2")]
    let lanDevices = [DeviceModel.mockLAN(name: "LAN1", ip: "192.168.1.100")]
    
    mockBTService.devicesToReturn = btDevices
    mockLANService.devicesToReturn = lanDevices
    
    let session = try await orchestrator.performFullScan()
    
    XCTAssertEqual(session.devicesFound, 3, "Should find 3 devices total")
    XCTAssertEqual(session.devices.count, 3, "Devices array should contain 3 devices")
    XCTAssertTrue(mockBTService.scanCalled, "Bluetooth scan should be called")
    XCTAssertTrue(mockLANService.scanCalled, "LAN scan should be called")
    XCTAssertNotNil(mockRepository.savedSession, "Session should be saved to repository")
  }
  
  // MARK: - Объединение результатов обоих сканирований
  @MainActor
  func testPerformFullScan_Success_CombinesDevicesCorrectly() async throws {
    let btDevices = [DeviceModel.mockBluetooth()]
    let lanDevices = [DeviceModel.mockLAN()]
    
    mockBTService.devicesToReturn = btDevices
    mockLANService.devicesToReturn = lanDevices
    
    let session = try await orchestrator.performFullScan()
    let bluetoothCount = session.devices.filter { $0.deviceType == .bluetooth }.count
    let lanCount = session.devices.filter { $0.deviceType == .lan }.count
    
    XCTAssertEqual(bluetoothCount, 1, "Should have 1 Bluetooth device")
    XCTAssertEqual(lanCount, 1, "Should have 1 LAN device")
  }
  
  // MARK: - Сохранение сессии через repository с корректными данными
  @MainActor
  func testPerformFullScan_Success_SavesSessionWithCorrectData() async throws {
    let btDevices = [DeviceModel.mockBluetooth(name: "Test BT")]
    let lanDevices = [DeviceModel.mockLAN(name: "Test LAN", ip: "192.168.1.50")]
    
    mockBTService.devicesToReturn = btDevices
    mockLANService.devicesToReturn = lanDevices
    
    let _ = try await orchestrator.performFullScan()
    
    XCTAssertNotNil(mockRepository.savedSession, "Session should be saved")
    XCTAssertEqual(mockRepository.savedSession?.devicesFound, 2, "Saved session should have 2 devices")
    XCTAssertEqual(mockRepository.savedSession?.devices.count, 2, "Saved devices array should have 2 items")
  }
  
  // MARK: - Обработка ошибки Bluetooth (остановка всех сканирований)
  func testPerformFullScan_BluetoothError_ThrowsErrorAndStopsScans() async throws {
    mockBTService.shouldThrowError = ScanError.bluetoothPoweredOff
    mockLANService.devicesToReturn = [DeviceModel.mockLAN()]
    
    do {
      _ = try await orchestrator.performFullScan()
      XCTFail("Should throw an error")
    } catch let error as ScanError {
      if case .bluetoothPoweredOff = error {
      } else {
        XCTFail("Should throw Bluetooth powered off error, got: \(error)")
      }
      XCTAssertTrue(mockBTService.stopCalled, "Bluetooth service should be stopped")
      XCTAssertTrue(mockLANService.stopCalled, "LAN service should be stopped")
      XCTAssertNil(mockRepository.savedSession, "Session should not be saved on error")
    } catch {
      XCTFail("Should throw ScanError")
    }
  }
  
  // MARK: - Обработка ошибки репозитория
  func testPerformFullScan_RepositoryError_ThrowsError() async throws {
    mockBTService.devicesToReturn = [DeviceModel.mockBluetooth()]
    mockLANService.devicesToReturn = [DeviceModel.mockLAN()]
    
    enum RepositoryError: Error {
      case saveFailed
    }
    mockRepository.shouldThrowError = RepositoryError.saveFailed
    
    do {
      _ = try await orchestrator.performFullScan()
      XCTFail("Should throw repository error")
    } catch {
      XCTAssertTrue(mockBTService.stopCalled, "Bluetooth service should be stopped on repository error")
      XCTAssertTrue(mockLANService.stopCalled, "LAN service should be stopped on repository error")
    }
  }
  
  // MARK: - Стоп сканирования
  func testStopAllScans_CallsBothServices() {
    orchestrator.stopAllScans()
    
    XCTAssertTrue(mockBTService.stopCalled, "Bluetooth service stop should be called")
    XCTAssertTrue(mockLANService.stopCalled, "LAN service stop should be called")
  }
}
