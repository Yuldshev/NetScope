import Foundation

// MARK: - Model
struct ScanResult {
  let ipAddress: String
  let openPorts: [Int]
  let scanDuration: TimeInterval
}

// MARK: - Implementation
final class TCPPortScanner {
  private let commonPorts = [80, 443, 22, 445, 8080, 139, 3389, 5000]
  
  func scanHost(ip: String, ports: [Int], timeout: TimeInterval) async -> ScanResult? {
    let startTime = Date()
    var openPorts: [Int] = []
    
    for port in ports {
      let isOpen = await connectToPort(ip: ip, port: port, timeout: timeout)
      if isOpen {
        openPorts.append(port)
        break
      }
    }
    
    guard !openPorts.isEmpty else { return nil }
    
    let duration = Date().timeIntervalSince(startTime)
    return ScanResult(ipAddress: ip, openPorts: openPorts, scanDuration: duration)
  }
  
  func scanMultipleHosts(ips: [String], ports: [Int], timeout: TimeInterval) async -> [ScanResult] {
    await withTaskGroup(of: ScanResult?.self) { group in
      for ip in ips {
        group.addTask {
          await self.scanHost(ip: ip, ports: ports, timeout: timeout)
        }
      }
      
      var results: [ScanResult] = []
      for await result in group {
        if let result = result {
          results.append(result)
        }
      }
      return results
    }
  }
}

// MARK: - Helper
private extension TCPPortScanner {
  func connectToPort(ip: String, port: Int, timeout: TimeInterval) async -> Bool {
    return await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .userInitiated).async {
        var hints = addrinfo()
        hints.ai_family = AF_INET
        hints.ai_socktype = SOCK_STREAM
        
        var result: UnsafeMutablePointer<addrinfo>?
        defer { if result != nil { freeaddrinfo(result) } }
        
        let status = getaddrinfo(ip, String(port), &hints, &result)
        guard status == 0, let addrInfo = result else {
          continuation.resume(returning: false)
          return
        }
        
        let socketFD = socket(
          addrInfo.pointee.ai_family,
          addrInfo.pointee.ai_socktype,
          addrInfo.pointee.ai_protocol
        )
        
        guard socketFD >= 0 else {
          continuation.resume(returning: false)
          return
        }
        defer { close(socketFD) }
        
        let flags = fcntl(socketFD, F_GETFL, 0)
        _ = fcntl(socketFD, F_SETFL, flags | O_NONBLOCK)
        
        let connectResult = connect(
          socketFD,
          addrInfo.pointee.ai_addr,
          addrInfo.pointee.ai_addrlen
        )
        
        if connectResult == 0 {
          continuation.resume(returning: true)
          return
        }
        
        if errno != EINPROGRESS {
          continuation.resume(returning: false)
          return
        }
        
        var pfd = pollfd(fd: socketFD, events: Int16(POLLOUT), revents: 0)
        let timeoutMsDouble = timeout * 1000.0
        let timeoutMs = timeoutMsDouble > Double(Int32.max) ? Int32(Int32.max) : Int32(timeoutMsDouble)
        
        let pollResult = withUnsafeMutablePointer(to: &pfd) { ptr -> Int32 in
          return poll(ptr, 1, timeoutMs)
        }
        
        if pollResult > 0 {
          var error: Int32 = 0
          var errorSize = socklen_t(MemoryLayout<Int32>.size)
          if getsockopt(socketFD, SOL_SOCKET, SO_ERROR, &error, &errorSize) == 0 {
            continuation.resume(returning: error == 0)
          } else {
            continuation.resume(returning: false)
          }
        } else {
          continuation.resume(returning: false)
        }
      }
    }
  }
}
