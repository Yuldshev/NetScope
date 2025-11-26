import Foundation

// MARK: - Model
struct IPRange {
  let priority: ScanPriority
  let ipAddresses: [String]
}

// MARK: - Enum
enum ScanPriority {
  case high    // .1-.50, .100-.150
  case medium  // .51-.99, .151-.200
  case low     // .201-.254
}

// MARK: - Implementation
final class IPRangeGenerator {
  func generateSmartRanges(baseIP: String, subnetMask: String) -> [IPRange] {
    let networkPrefix = extractNetworkPrefix(baseIP, subnetMask)
    
    var ranges: [IPRange] = []
    
    var highPriority: [String] = []
    highPriority.append(contentsOf: (1...50).map { "\(networkPrefix).\($0)" })
    highPriority.append(contentsOf: (100...150).map { "\(networkPrefix).\($0)" })
    ranges.append(IPRange(priority: .high, ipAddresses: highPriority))
    
    var mediumPriority: [String] = []
    mediumPriority.append(contentsOf: (51...99).map { "\(networkPrefix).\($0)" })
    mediumPriority.append(contentsOf: (151...200).map { "\(networkPrefix).\($0)" })
    ranges.append(IPRange(priority: .medium, ipAddresses: mediumPriority))
    
    let lowPriority = (201...254).map { "\(networkPrefix).\($0)" }
    ranges.append(IPRange(priority: .low, ipAddresses: lowPriority))
    
    return ranges
  }
  
  private func extractNetworkPrefix(_ ip: String, _ mask: String) -> String {
    let ipOctets = ip.split(separator: ".").compactMap { UInt8($0) }
    let maskOctets = mask.split(separator: ".").compactMap { UInt8($0) }
    
    let networkOctets = zip(ipOctets, maskOctets).map { $0 & $1 }
    
    return networkOctets.dropLast().map(String.init).joined(separator: ".")
  }
}
