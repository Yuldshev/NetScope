import Foundation

// MARK: - Model
struct NetworkInfo {
  let localIP: String
  let subnetMask: String
  let broadcastAddress: String
  let cidrPrefix: Int
}

// MARK: - Implementation
final class NetworkInfoProvider {
  func getCurrentNetworkInfo() throws -> NetworkInfo {
    guard let localIP = getWiFiAddress() else {
      throw ScanError.networkUnavailable
    }
    
    guard let subnetMask = getSubnetMask() else {
      throw ScanError.networkUnavailable
    }
    
    let broadcast = calculateBroadcast(ip: localIP, mask: subnetMask)
    let cidr = calculateCIDR(mask: subnetMask)
    
    return NetworkInfo(
      localIP: localIP,
      subnetMask: subnetMask,
      broadcastAddress: broadcast,
      cidrPrefix: cidr
    )
  }
}

// MARK: - Helper
private extension NetworkInfoProvider {
  func getWiFiAddress() -> String? {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    defer { freeifaddrs(ifaddr) }
    
    var ptr = ifaddr
    while ptr != nil {
      defer { ptr = ptr?.pointee.ifa_next }
      
      guard let interface = ptr?.pointee else { continue }
      let addrFamily = interface.ifa_addr.pointee.sa_family
      
      if addrFamily == UInt8(AF_INET) {
        let name = String(cString: interface.ifa_name)
        if name == "en0" {
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(
            interface.ifa_addr,
            socklen_t(interface.ifa_addr.pointee.sa_len),
            &hostname,
            socklen_t(hostname.count),
            nil,
            socklen_t(0),
            NI_NUMERICHOST
          )
          address = String(cString: hostname)
        }
      }
    }
    return address
  }
  
  func getSubnetMask() -> String? {
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    defer { freeifaddrs(ifaddr) }
    
    var ptr = ifaddr
    while ptr != nil {
      defer { ptr = ptr?.pointee.ifa_next }
      
      guard let interface = ptr?.pointee else { continue }
      let addrFamily = interface.ifa_addr.pointee.sa_family
      
      if addrFamily == UInt8(AF_INET) {
        let name = String(cString: interface.ifa_name)
        if name == "en0", let netmask = interface.ifa_netmask {
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(
            netmask,
            socklen_t(netmask.pointee.sa_len),
            &hostname,
            socklen_t(hostname.count),
            nil,
            socklen_t(0),
            NI_NUMERICHOST
          )
          return String(cString: hostname)
        }
      }
    }
    return nil
  }
  
  func calculateBroadcast(ip: String, mask: String) -> String {
    let ipOctets = ip.split(separator: ".").compactMap { UInt8($0) }
    let maskOctets = mask.split(separator: ".").compactMap { UInt8($0) }
    
    let broadcastOctets = zip(ipOctets, maskOctets).map { $0 | ~$1 }
    return broadcastOctets.map(String.init).joined(separator: ".")
  }
  
  func calculateCIDR(mask: String) -> Int {
    let octets = mask.split(separator: ".").compactMap { UInt8($0) }
    return octets.reduce(0) { $0 + $1.nonzeroBitCount }
  }
}
