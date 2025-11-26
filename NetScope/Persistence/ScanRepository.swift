import Foundation
import CoreData
import Combine

// MARK: - Protocol
protocol ScanRepositoryProtocol {
  func saveScanSession(_ session: ScanSessionModel) async throws -> ScanSessionModel
  func fetchAllSessions() async throws -> [ScanSessionModel]
  func fetchSessions(from startDate: Date, to endDate: Date) async throws -> [ScanSessionModel]
  func fetchSessions(matching deviceName: String) async throws -> [ScanSessionModel]
  func deleteSession(_ sessionId: UUID) async throws
  func deleteAllSessions() async throws
}

// MARK: - Implementation
final class ScanRepository: ScanRepositoryProtocol {
  
  private let coreDataStack: CoreDataStack
  
  init(coreDataStack: CoreDataStack = .shared) {
    self.coreDataStack = coreDataStack
  }
  
  func saveScanSession(_ session: ScanSessionModel) async throws -> ScanSessionModel {
    let context = coreDataStack.newBackgroundContext()
    
    return try await context.perform {
      let scanSession = CDScanSession(context: context)
      scanSession.id = session.id
      scanSession.timestamp = session.timestamp
      scanSession.devicesFound = Int16(session.devicesFound)
      
      for device in session.devices {
        switch device {
          case .bluetooth(let btDevice):
            let btEntity = CDBluetoothDevice(context: context)
            btEntity.id = btDevice.id
            btEntity.name = btDevice.name
            btEntity.deviceType = DeviceType.bluetooth.rawValue
            btEntity.discoveredAt = btDevice.discoveredAt
            btEntity.uuid = btDevice.uuid
            btEntity.rssi = Int16(btDevice.rssi)
            btEntity.connectionStatus = btDevice.connectionStatus.rawValue
            btEntity.scanSession = scanSession
            
          case .lan(let lanDevice):
            let lanEntity = CDLANDevice(context: context)
            lanEntity.id = lanDevice.id
            lanEntity.name = lanDevice.name
            lanEntity.deviceType = DeviceType.lan.rawValue
            lanEntity.discoveredAt = lanDevice.discoveredAt
            lanEntity.ipAddress = lanDevice.ipAddress
            lanEntity.macAddress = lanDevice.macAddress
            lanEntity.hostName = lanDevice.hostName
            lanEntity.scanSession = scanSession
        }
      }
      
      try context.save()
      
      return scanSession.toModel()
    }
  }
  
  func fetchAllSessions() async throws -> [ScanSessionModel] {
    let context = coreDataStack.viewContext
    
    return try await context.perform {
      let request = CDScanSession.fetchRequest()
      request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
      
      let sessions = try context.fetch(request)
      return sessions.map { $0.toModel() }
    }
  }
  
  func fetchSessions(from startDate: Date, to endDate: Date) async throws -> [ScanSessionModel] {
    let context = coreDataStack.viewContext
    
    return try await context.perform {
      let request = CDScanSession.fetchRequest()
      request.predicate = NSPredicate(
        format: "timestamp >= %@ AND timestamp <= %@",
        startDate as NSDate,
        endDate as NSDate
      )
      request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
      
      let sessions = try context.fetch(request)
      return sessions.map { $0.toModel() }
    }
  }
  
  func fetchSessions(matching deviceName: String) async throws -> [ScanSessionModel] {
    let context = coreDataStack.viewContext
    
    return try await context.perform {
      let request = CDScanSession.fetchRequest()
      request.predicate = NSPredicate(
        format: "ANY devices.name CONTAINS[cd] %@",
        deviceName
      )
      request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
      
      let sessions = try context.fetch(request)
      return sessions.map { $0.toModel() }
    }
  }
  
  func deleteSession(_ sessionId: UUID) async throws {
    let context = coreDataStack.newBackgroundContext()
    
    try await context.perform {
      let request = CDScanSession.fetchRequest()
      request.predicate = NSPredicate(format: "id == %@", sessionId as CVarArg)
      
      if let session = try context.fetch(request).first {
        context.delete(session)
        try context.save()
      }
    }
  }
  
  func deleteAllSessions() async throws {
    let context = coreDataStack.newBackgroundContext()
    
    try await context.perform {
      let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDScanSession.fetchRequest()
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      
      try context.execute(deleteRequest)
      try context.save()
    }
  }
}
