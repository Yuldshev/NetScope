import XCTest
@testable import NetScope

final class IPRangeGeneratorTests: XCTestCase {
  var generator: IPRangeGenerator!
  
  override func setUp() {
    super.setUp()
    generator = IPRangeGenerator()
  }
  
  override func tearDown() {
    generator = nil
    super.tearDown()
  }
  
  // MARK: - Генерация трех приоритетных диапазонов
  func testGenerateSmartRanges_ReturnsThreeRanges() throws {
    let baseIP = "192.168.1.100"
    let subnetMask = "255.255.255.0"
    let ranges = generator.generateSmartRanges(baseIP: baseIP, subnetMask: subnetMask)
    
    XCTAssertEqual(ranges.count, 3, "Should generate exactly 3 priority ranges")
    
    let priorities = ranges.map { $0.priority }
    XCTAssertTrue(priorities.contains(.high), "Should contain high priority range")
    XCTAssertTrue(priorities.contains(.medium), "Should contain medium priority range")
    XCTAssertTrue(priorities.contains(.low), "Should contain low priority range")
  }
  
  // MARK: - High priority содержит корректные IP (1-50, 100-150)
  @MainActor
  func testGenerateSmartRanges_HighPriority_ContainsCorrectIPs() throws {
    let baseIP = "192.168.1.100"
    let subnetMask = "255.255.255.0"
    let ranges = generator.generateSmartRanges(baseIP: baseIP, subnetMask: subnetMask)
    let highPriorityRange = try XCTUnwrap(ranges.first { $0.priority == .high })
    
    XCTAssertEqual(highPriorityRange.ipAddresses.count, 101, "High priority should have 101 IPs (1-50 + 100-150)")
    XCTAssertTrue(highPriorityRange.ipAddresses.contains("192.168.1.1"), "Should contain .1")
    XCTAssertTrue(highPriorityRange.ipAddresses.contains("192.168.1.50"), "Should contain .50")
    XCTAssertTrue(highPriorityRange.ipAddresses.contains("192.168.1.100"), "Should contain .100")
    XCTAssertTrue(highPriorityRange.ipAddresses.contains("192.168.1.150"), "Should contain .150")
    XCTAssertFalse(highPriorityRange.ipAddresses.contains("192.168.1.51"), "Should not contain .51")
    XCTAssertFalse(highPriorityRange.ipAddresses.contains("192.168.1.99"), "Should not contain .99")
    XCTAssertFalse(highPriorityRange.ipAddresses.contains("192.168.1.151"), "Should not contain .151")
  }
  
  // MARK: - Правильное извлечение сетевого префикса
  func testGenerateSmartRanges_ExtractsCorrectNetworkPrefix() throws {
    let baseIP1 = "192.168.1.100"
    let subnetMask1 = "255.255.255.0"
    let ranges1 = generator.generateSmartRanges(baseIP: baseIP1, subnetMask: subnetMask1)
    let firstIP1 = try XCTUnwrap(ranges1.first?.ipAddresses.first)
    
    XCTAssertTrue(firstIP1.hasPrefix("192.168.1."), "Network prefix should be 192.168.1")
    
    let baseIP2 = "10.0.5.50"
    let subnetMask2 = "255.255.255.0"
    let ranges2 = generator.generateSmartRanges(baseIP: baseIP2, subnetMask: subnetMask2)
    let firstIP2 = try XCTUnwrap(ranges2.first?.ipAddresses.first)
    
    XCTAssertTrue(firstIP2.hasPrefix("10.0.5."), "Network prefix should be 10.0.5")
    
    let baseIP3 = "172.16.20.100"
    let subnetMask3 = "255.255.0.0"
    let ranges3 = generator.generateSmartRanges(baseIP: baseIP3, subnetMask: subnetMask3)
    let firstIP3 = try XCTUnwrap(ranges3.first?.ipAddresses.first)
    
    XCTAssertTrue(firstIP3.hasPrefix("172.16.0."), "Network prefix should be 172.16.0 for /16 mask")
  }
  
  // MARK: - Валидация сгенерированных IP адресов
  func testGenerateSmartRanges_AllIPsAreValid() throws {
    let baseIP = "192.168.1.100"
    let subnetMask = "255.255.255.0"
    let ranges = generator.generateSmartRanges(baseIP: baseIP, subnetMask: subnetMask)
    
    for range in ranges {
      for ip in range.ipAddresses {
        let components = ip.split(separator: ".")
        XCTAssertEqual(components.count, 4, "IP \(ip) should have 4 octets")
        
        for component in components {
          if let value = UInt8(component) {
            XCTAssertLessThanOrEqual(value, 255, "Octet \(component) should be <= 255")
          } else {
            XCTFail("Invalid octet: \(component) in IP \(ip)")
          }
        }
      }
    }
  }
  
  // MARK: - Medium and Low priority ranges
  @MainActor
  func testGenerateSmartRanges_MediumPriority_ContainsCorrectIPs() throws {
    let baseIP = "192.168.1.100"
    let subnetMask = "255.255.255.0"
    let ranges = generator.generateSmartRanges(baseIP: baseIP, subnetMask: subnetMask)
    let mediumPriorityRange = try XCTUnwrap(ranges.first { $0.priority == .medium })
    
    XCTAssertEqual(mediumPriorityRange.ipAddresses.count, 99, "Medium priority should have 99 IPs (51-99 + 151-200)")
    XCTAssertTrue(mediumPriorityRange.ipAddresses.contains("192.168.1.51"), "Should contain .51")
    XCTAssertTrue(mediumPriorityRange.ipAddresses.contains("192.168.1.99"), "Should contain .99")
    XCTAssertTrue(mediumPriorityRange.ipAddresses.contains("192.168.1.151"), "Should contain .151")
    XCTAssertTrue(mediumPriorityRange.ipAddresses.contains("192.168.1.200"), "Should contain .200")
  }
  
  @MainActor
  func testGenerateSmartRanges_LowPriority_ContainsCorrectIPs() throws {
    let baseIP = "192.168.1.100"
    let subnetMask = "255.255.255.0"
    let ranges = generator.generateSmartRanges(baseIP: baseIP, subnetMask: subnetMask)
    let lowPriorityRange = try XCTUnwrap(ranges.first { $0.priority == .low })
    
    XCTAssertEqual(lowPriorityRange.ipAddresses.count, 54, "Low priority should have 54 IPs (201-254)")
    XCTAssertTrue(lowPriorityRange.ipAddresses.contains("192.168.1.201"), "Should contain .201")
    XCTAssertTrue(lowPriorityRange.ipAddresses.contains("192.168.1.254"), "Should contain .254")
    XCTAssertFalse(lowPriorityRange.ipAddresses.contains("192.168.1.200"), "Should not contain .200")
    XCTAssertFalse(lowPriorityRange.ipAddresses.contains("192.168.1.255"), "Should not contain .255 (broadcast)")
  }
  
  // MARK: - Total IP count
  func testGenerateSmartRanges_TotalIPCount_IsCorrect() throws {
    let baseIP = "192.168.1.100"
    let subnetMask = "255.255.255.0"
    let ranges = generator.generateSmartRanges(baseIP: baseIP, subnetMask: subnetMask)
    let totalIPs = ranges.reduce(0) { $0 + $1.ipAddresses.count }
    
    XCTAssertEqual(totalIPs, 254, "Should generate 254 total IPs (1-254, excluding 0 and 255)")
  }
}
