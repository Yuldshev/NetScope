import Foundation
@testable import NetScope

final class MockScanRepository: ScanRepositoryProtocol {
  var sessionsToReturn: [ScanSessionModel] = []
  var shouldThrowError: Error?
  var savedSession: ScanSessionModel?
  var deletedSessionIds: [UUID] = []
  var deleteAllCalled = false
  
  func saveScanSession(_ session: ScanSessionModel) async throws -> ScanSessionModel {
    if let error = shouldThrowError {
      throw error
    }
    savedSession = session
    return session
  }
  
  func fetchAllSessions() async throws -> [ScanSessionModel] {
    if let error = shouldThrowError {
      throw error
    }
    return sessionsToReturn
  }
  
  func fetchSessions(from startDate: Date, to endDate: Date) async throws -> [ScanSessionModel] {
    if let error = shouldThrowError {
      throw error
    }
    return sessionsToReturn.filter {
      $0.timestamp >= startDate && $0.timestamp <= endDate
    }
  }
  
  func fetchSessions(matching deviceName: String) async throws -> [ScanSessionModel] {
    if let error = shouldThrowError {
      throw error
    }
    return sessionsToReturn
  }
  
  func deleteSession(_ sessionId: UUID) async throws {
    if let error = shouldThrowError {
      throw error
    }
    deletedSessionIds.append(sessionId)
  }
  
  func deleteAllSessions() async throws {
    if let error = shouldThrowError {
      throw error
    }
    deleteAllCalled = true
    sessionsToReturn.removeAll()
  }
}
