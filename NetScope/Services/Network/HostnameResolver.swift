import Foundation

final class HostnameResolver {
  func resolveHostname(for ip: String, timeout: TimeInterval) async -> String? {
    return await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .utility).async {
        var hints = addrinfo()
        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_STREAM
        
        var result: UnsafeMutablePointer<addrinfo>?
        defer { if result != nil { freeaddrinfo(result) } }
        
        guard getaddrinfo(ip, nil, &hints, &result) == 0,
              let addr = result?.pointee.ai_addr else {
          continuation.resume(returning: nil)
          return
        }
        
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let flags = NI_NAMEREQD
        
        let status = getnameinfo(
          addr,
          socklen_t(addr.pointee.sa_len),
          &hostname,
          socklen_t(hostname.count),
          nil,
          0,
          flags
        )
        
        if status == 0 {
          continuation.resume(returning: String(cString: hostname))
        } else {
          continuation.resume(returning: nil)
        }
      }
    }
  }
  
  func resolveMultiple(ips: [String], timeout: TimeInterval) async -> [String: String] {
    await withTaskGroup(of: (String, String?).self) { group in
      for ip in ips {
        group.addTask {
          (ip, await self.resolveHostname(for: ip, timeout: timeout))
        }
      }
      
      var results: [String: String] = [:]
      for await (ip, hostname) in group {
        if let hostname = hostname {
          results[ip] = hostname
        }
      }
      return results
    }
  }
}
