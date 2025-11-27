import XCTest
@testable import NetScope

@MainActor
final class HistoryViewModelTests: XCTestCase {
  var viewModel: HistoryViewModel!
  var mockRepository: MockScanRepository!
  
  override func setUp() async throws {
    try await super.setUp()
    mockRepository = MockScanRepository()
    viewModel = HistoryViewModel(repository: mockRepository)
  }
  
  override func tearDown() async throws {
    viewModel = nil
    mockRepository = nil
    try await super.tearDown()
  }
  
  // MARK: - Успешная загрузка сессий из repository
  func testLoadSessions_Success_UpdatesAllSessions() async throws {
    let session1 = ScanSessionModel.mock(devicesCount: 5)
    let session2 = ScanSessionModel.mock(devicesCount: 3)
    mockRepository.sessionsToReturn = [session1, session2]
    
    XCTAssertEqual(viewModel.loadingState, .idle, "Initial state should be idle")
    
    viewModel.loadSessions()
    
    try await Task.sleep(nanoseconds: 100_000_000)
    
    XCTAssertEqual(viewModel.loadingState, .loaded, "State should be loaded")
    XCTAssertEqual(viewModel.allSessions.count, 2, "Should have 2 sessions")
    XCTAssertEqual(viewModel.filteredSessions.count, 2, "Filtered sessions should also have 2 sessions initially")
    XCTAssertTrue(viewModel.hasSessions, "hasSessions should be true")
    XCTAssertEqual(viewModel.totalSessionCount, 2, "Total session count should be 2")
  }
  
  // MARK: - Фильтрация по диапазону дат
  func testDateFilter_FiltersSessionsCorrectly() async throws {
    let calendar = Calendar.current
    let now = Date()
    let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
    let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now)!
    let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
    let session1 = ScanSessionModel.mockWithDate(date: now, devicesCount: 2)
    let session2 = ScanSessionModel.mockWithDate(date: yesterday, devicesCount: 3)
    let session3 = ScanSessionModel.mockWithDate(date: twoDaysAgo, devicesCount: 1)
    let session4 = ScanSessionModel.mockWithDate(date: weekAgo, devicesCount: 4)
    
    mockRepository.sessionsToReturn = [session1, session2, session3, session4]
    
    viewModel.loadSessions()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    viewModel.filterStartDate = twoDaysAgo
    viewModel.filterEndDate = now
    
    XCTAssertEqual(viewModel.filteredSessions.count, 3, "Should filter to 3 sessions within last 2 days")
    XCTAssertTrue(viewModel.isFilteringActive, "Filtering should be active")
    XCTAssertEqual(viewModel.filteredSessionCount, 3, "Filtered count should be 3")
  }
  
  // MARK: - Быстрые фильтры
  func testFilterToday_SetsCorrectDateRange() async throws {
    let calendar = Calendar.current
    let now = Date()
    let today = calendar.startOfDay(for: now)
    let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
    
    let sessionToday = ScanSessionModel.mockWithDate(date: now, devicesCount: 2)
    let sessionYesterday = ScanSessionModel.mockWithDate(date: yesterday, devicesCount: 3)
    
    mockRepository.sessionsToReturn = [sessionToday, sessionYesterday]
    
    viewModel.loadSessions()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    viewModel.filterToday()
    
    XCTAssertNotNil(viewModel.filterStartDate, "Filter start date should be set")
    XCTAssertNotNil(viewModel.filterEndDate, "Filter end date should be set")
    XCTAssertEqual(viewModel.filterStartDate, today, "Start date should be start of today")
    XCTAssertTrue(viewModel.isFilteringActive, "Filtering should be active")
    XCTAssertEqual(viewModel.filteredSessions.count, 1, "Should only show today's sessions")
  }
  
  func testFilterLastWeek_SetsCorrectDateRange() async throws {
    let calendar = Calendar.current
    let now = Date()
    let expectedStartDate = calendar.date(byAdding: .day, value: -7, to: now)!
    
    viewModel.filterLastWeek()
    
    XCTAssertNotNil(viewModel.filterStartDate, "Filter start date should be set")
    XCTAssertNotNil(viewModel.filterEndDate, "Filter end date should be set")
    
    let startDateDiff = abs(viewModel.filterStartDate!.timeIntervalSince(expectedStartDate))
    XCTAssertLessThan(startDateDiff, 1.0, "Start date should be approximately 7 days ago")
  }
  
  func testFilterLastMonth_SetsCorrectDateRange() async throws {
    let calendar = Calendar.current
    let now = Date()
    let expectedStartDate = calendar.date(byAdding: .day, value: -30, to: now)!
    
    viewModel.filterLastMonth()
    
    XCTAssertNotNil(viewModel.filterStartDate, "Filter start date should be set")
    XCTAssertNotNil(viewModel.filterEndDate, "Filter end date should be set")
    
    let startDateDiff = abs(viewModel.filterStartDate!.timeIntervalSince(expectedStartDate))
    XCTAssertLessThan(startDateDiff, 1.0, "Start date should be approximately 30 days ago")
  }
  
  // MARK: - Удаление сессии и обновление списков
  func testDeleteSession_RemovesFromBothLists() async throws {
    let session1 = ScanSessionModel.mock(devicesCount: 3)
    let session2 = ScanSessionModel.mock(devicesCount: 5)
    mockRepository.sessionsToReturn = [session1, session2]
    
    viewModel.loadSessions()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    XCTAssertEqual(viewModel.allSessions.count, 2, "Should have 2 sessions initially")
    
    viewModel.deleteSession(session1)
    try await Task.sleep(nanoseconds: 100_000_000)
    
    XCTAssertTrue(mockRepository.deletedSessionIds.contains(session1.id), "Session ID should be in deleted list")
    XCTAssertEqual(viewModel.allSessions.count, 1, "Should have 1 session after deletion")
    XCTAssertEqual(viewModel.filteredSessions.count, 1, "Filtered sessions should also have 1 session")
    XCTAssertNotNil(viewModel.alertConfig, "Alert should be shown after deletion")
  }
  
  // MARK: - Очистка фильтра и восстановление всех сессий
  func testClearFilter_ResetsFilteredSessions() async throws {
    let session1 = ScanSessionModel.mock(devicesCount: 2)
    let session2 = ScanSessionModel.mock(devicesCount: 3)
    mockRepository.sessionsToReturn = [session1, session2]
    
    viewModel.loadSessions()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    viewModel.filterToday()
    XCTAssertTrue(viewModel.isFilteringActive, "Filtering should be active")
    
    viewModel.clearFilter()
    
    XCTAssertNil(viewModel.filterStartDate, "Filter start date should be nil")
    XCTAssertNil(viewModel.filterEndDate, "Filter end date should be nil")
    XCTAssertFalse(viewModel.isFilteringActive, "Filtering should be inactive")
    XCTAssertEqual(viewModel.filteredSessions.count, viewModel.allSessions.count, "All sessions should be visible")
  }
  
  // MARK: - Test Bonus: Delete all sessions
  func testDeleteAllSessions_ClearsAllLists() async throws {
    let session1 = ScanSessionModel.mock(devicesCount: 2)
    let session2 = ScanSessionModel.mock(devicesCount: 3)
    mockRepository.sessionsToReturn = [session1, session2]
    
    viewModel.loadSessions()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    XCTAssertEqual(viewModel.allSessions.count, 2, "Should have 2 sessions initially")
    
    viewModel.deleteAllSessions()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    XCTAssertTrue(mockRepository.deleteAllCalled, "Delete all should be called on repository")
    XCTAssertEqual(viewModel.allSessions.count, 0, "All sessions should be empty")
    XCTAssertEqual(viewModel.filteredSessions.count, 0, "Filtered sessions should be empty")
    XCTAssertFalse(viewModel.hasSessions, "hasSessions should be false")
  }
  
  // MARK: - Test Bonus: Loading error
  func testLoadSessions_Error_UpdatesStateToError() async throws {
    enum TestError: Error {
      case loadFailed
    }
    mockRepository.shouldThrowError = TestError.loadFailed
    
    viewModel.loadSessions()
    try await Task.sleep(nanoseconds: 100_000_000)
    
    if case .error = viewModel.loadingState {
      XCTAssertNotNil(viewModel.alertConfig, "Alert should be shown for error")
    } else {
      XCTFail("Loading state should be error")
    }
  }
}
