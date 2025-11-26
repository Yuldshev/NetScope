import Foundation
import Darwin

// MARK: - Darwin Routing Constants
private let RTAX_DST = 0
private let RTAX_GATEWAY = 1
private let RTAX_MAX = 8
private let RTF_LLINFO: Int32 = 0x400

// MARK: - Routing Message Header
private struct rt_msghdr {
  var rtm_msglen: UInt16
  var rtm_version: UInt8
  var rtm_type: UInt8
  var rtm_index: UInt16
  var rtm_flags: Int32
  var rtm_addrs: Int32
  var rtm_pid: pid_t
  var rtm_seq: Int32
  var rtm_errno: Int32
  var rtm_use: Int32
  var rtm_inits: UInt32
  var rtm_rmx: rt_metrics
}

private struct rt_metrics {
  var rmx_locks: UInt32
  var rmx_mtu: UInt32
  var rmx_hopcount: UInt32
  var rmx_expire: Int32
  var rmx_recvpipe: UInt32
  var rmx_sendpipe: UInt32
  var rmx_ssthresh: UInt32
  var rmx_rtt: UInt32
  var rmx_rttvar: UInt32
  var rmx_pksent: UInt32
  var rmx_state: UInt32
  var rmx_filler: (UInt32, UInt32, UInt32)
}

struct ARPEntry {
  let ipAddress: String
  let macAddress: String
}

final class ARPTableReader {
  func readARPTable() throws -> [ARPEntry] {
    var mib: [Int32] = [CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_LLINFO]
    var len: size_t = 0
    
    guard sysctl(&mib, UInt32(mib.count), nil, &len, nil, 0) == 0 else {
      throw ScanError.scanFailed("Не удалось прочитать ARP таблицу")
    }
    
    var buffer = [UInt8](repeating: 0, count: len)
    
    guard sysctl(&mib, UInt32(mib.count), &buffer, &len, nil, 0) == 0 else {
      throw ScanError.scanFailed("Ошибка чтения ARP данных")
    }
    
    let data = Data(buffer)
    return parseARPData(data)
  }
  
  func getMACAddress(for ip: String) -> String? {
    guard let entries = try? readARPTable() else { return nil }
    return entries.first(where: { $0.ipAddress == ip })?.macAddress
  }
}

// MARK: - Helper
private extension ARPTableReader {
  func parseARPData(_ data: Data) -> [ARPEntry] {
    var entries: [ARPEntry] = []
    var offset = 0
    
    data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
      while offset < data.count {
        guard offset + MemoryLayout<rt_msghdr>.size <= data.count else { break }
        
        let rtm = bytes.load(fromByteOffset: offset, as: rt_msghdr.self)
        
        guard rtm.rtm_msglen > 0 else {
          offset += MemoryLayout<rt_msghdr>.size
          continue
        }
        
        var addrOffset = offset + MemoryLayout<rt_msghdr>.size
        var ipAddress: String?
        var macAddress: String?
        
        for i in 0..<Int(RTAX_MAX) {
          guard rtm.rtm_addrs & (1 << i) != 0 else { continue }
          guard addrOffset < data.count else { break }
          
          let sa = bytes.load(fromByteOffset: addrOffset, as: sockaddr.self)
          
          if i == Int(RTAX_DST) && sa.sa_family == UInt8(AF_INET) {
            let sin = bytes.load(fromByteOffset: addrOffset, as: sockaddr_in.self)
            var addr = sin.sin_addr
            var buf = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
            inet_ntop(AF_INET, &addr, &buf, socklen_t(INET_ADDRSTRLEN))
            ipAddress = String(cString: buf)
          }
          
          if i == Int(RTAX_GATEWAY) && sa.sa_family == UInt8(AF_LINK) {
            let sdl = bytes.load(fromByteOffset: addrOffset, as: sockaddr_dl.self)
            
            let macData = withUnsafeBytes(of: sdl.sdl_data) { ptr -> [UInt8] in
              let nameLen = Int(sdl.sdl_nlen)
              let addrLen = Int(sdl.sdl_alen)
              guard addrLen == 6 else { return [] }
              return Array(ptr[nameLen..<(nameLen + addrLen)])
            }
            
            if macData.count == 6 {
              macAddress = macData.map { String(format: "%02X", $0) }
                .joined(separator: ":")
            }
          }
          
          let saLen = Int(sa.sa_len)
          let alignedLen = saLen > 0 ? ((saLen + 3) & ~3) : MemoryLayout<sockaddr>.size
          addrOffset += alignedLen
        }
        
        if let ip = ipAddress, let mac = macAddress {
          entries.append(ARPEntry(ipAddress: ip, macAddress: mac))
        }
        
        offset += Int(rtm.rtm_msglen)
      }
    }
    
    return entries
  }
}
