import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
  // MARK: - Published Properties
  @Published private(set) var allSessions: [ScanSessionModel] = []
  @Published private(set) var filteredSessions: [ScanSessionModel] = []
  @Published private(set) var loadingState: LoadingState = .idle
  @Published var alertConfig: AlertConfig?
  @Published var filterStartDate: Date? { didSet { applyDateFilter() }}
  @Published var filterEndDate: Date? { didSet { applyDateFilter() }}
  @Published var isFilteringActive: Bool = false
  @Published private(set) var isDataLoaded: Bool = false
  
  private let repository: ScanRepositoryProtocol
  
  // MARK: - Computed Properties
  var totalSessionCount: Int {
    allSessions.count
  }
  
  var filteredSessionCount: Int {
    filteredSessions.count
  }
  
  var hasSessions: Bool {
    !allSessions.isEmpty
  }
  
  var isLoading: Bool {
    loadingState == .loading
  }
  
  var isTodayFilterActive: Bool {
    guard let start = filterStartDate, let end = filterEndDate else { return false }
    let calendar = Calendar.current
    let now = Date()
    let todayStart = calendar.startOfDay(for: now)
    return calendar.isDate(start, inSameDayAs: todayStart) &&
    calendar.isDate(end, inSameDayAs: now)
  }
  
  var isWeekFilterActive: Bool {
    guard let start = filterStartDate, let end = filterEndDate else { return false }
    let calendar = Calendar.current
    let now = Date()
    guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else { return false }
    return calendar.isDate(start, inSameDayAs: weekAgo) &&
    calendar.isDate(end, inSameDayAs: now)
  }
  
  var isMonthFilterActive: Bool {
    guard let start = filterStartDate, let end = filterEndDate else { return false }
    let calendar = Calendar.current
    let now = Date()
    guard let monthAgo = calendar.date(byAdding: .day, value: -30, to: now) else { return false }
    return calendar.isDate(start, inSameDayAs: monthAgo) &&
    calendar.isDate(end, inSameDayAs: now)
  }
  
  init(repository: ScanRepositoryProtocol) {
    self.repository = repository
  }
  
  convenience init() {
    self.init(repository: ScanRepository())
  }
  
  func loadSessions(forceReload: Bool = false) {
    guard forceReload || !isDataLoaded else { return }
    guard loadingState != .loading else { return }
    
    loadingState = .loading
    
    Task { @MainActor in
      do {
        let sessions = try await repository.fetchAllSessions()
        self.allSessions = sessions
        self.applyDateFilter()
        self.loadingState = .loaded
      } catch {
        self.loadingState = .error(error.localizedDescription)
        self.showAlert(
          title: "Ошибка загрузки",
          message: "Не удалось загрузить историю сканирований: \(error.localizedDescription)"
        )
      }
    }
  }
  
  func refreshAfterChange() {
    isDataLoaded = false
    loadSessions(forceReload: true)
  }
  
  func deleteSession(_ session: ScanSessionModel) {
    Task { @MainActor in
      do {
        try await repository.deleteSession(session.id)
        self.allSessions.removeAll { $0.id == session.id }
        self.filteredSessions.removeAll { $0.id == session.id }
        
        self.showAlert(
          title: "Удалено",
          message: "Сессия сканирования удалена"
        )
      } catch {
        self.showAlert(
          title: "Ошибка удаления",
          message: "Не удалось удалить сессию сканирования: \(error.localizedDescription)"
        )
      }
    }
  }
  
  func deleteSessions(at offsets: IndexSet) {
    let sessionsToDelete = offsets.map { filteredSessions[$0] }
    
    Task { @MainActor in
      do {
        for session in sessionsToDelete {
          try await repository.deleteSession(session.id)
        }
        let deletedIds = Set(sessionsToDelete.map { $0.id })
        self.allSessions.removeAll { deletedIds.contains($0.id) }
        self.filteredSessions.removeAll { deletedIds.contains($0.id) }
        
        self.showAlert(
          title: "Удалено",
          message: "Удалено сессий: \(sessionsToDelete.count)"
        )
      } catch {
        self.showAlert(
          title: "Ошибка удаления",
          message: "Не удалось удалить сессии: \(error.localizedDescription)"
        )
      }
    }
  }
  
  func deleteAllSessions() {
    Task { @MainActor in
      do {
        try await repository.deleteAllSessions()
        self.allSessions.removeAll()
        self.filteredSessions.removeAll()
        self.showAlert(title: "Удалено", message: "Вся история удалена")
      } catch {
        self.showAlert(
          title: "Ошибка удаления",
          message: "Не удалось удалить историю: \(error.localizedDescription)"
        )
      }
    }
  }
  
  func applyDateFilter() {
    guard let startDate = filterStartDate, let endDate = filterEndDate else {
      filteredSessions = allSessions
      isFilteringActive = false
      return
    }
    
    let adjustedEndDate = Calendar.current.date(
      bySettingHour: 23,
      minute: 59,
      second: 59,
      of: endDate
    ) ?? endDate
    
    filteredSessions = allSessions.filter { session in
      session.timestamp >= startDate && session.timestamp <= adjustedEndDate
    }
    
    isFilteringActive = true
  }
  
  func clearFilter() {
    filterStartDate = nil
    filterEndDate = nil
    filteredSessions = allSessions
    isFilteringActive = false
  }
  
  func filterLastWeek() {
    let now = Date()
    filterEndDate = now
    filterStartDate = Calendar.current.date(byAdding: .day, value: -7, to: now)
  }
  
  func filterLastMonth() {
    let now = Date()
    filterEndDate = now
    filterStartDate = Calendar.current.date(byAdding: .day, value: -30, to: now)
  }
  
  func filterToday() {
    let now = Date()
    filterEndDate = now
    filterStartDate = Calendar.current.startOfDay(for: now)
  }
  
  // MARK: - Private Methods
  private func showAlert(title: String, message: String) {
    alertConfig = AlertConfig(
      title: title,
      message: message
    )
  }
}

// MARK: - Supporting Types
enum LoadingState: Equatable {
  case idle
  case loading
  case loaded
  case error(String)
}

// MARK: - Calendar Extension (Helper)
private extension Calendar {
  func startOfDay(for date: Date) -> Date {
    return self.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? date
  }
}
